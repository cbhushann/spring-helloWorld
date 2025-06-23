pipeline {
  agent any

  environment {
    IMAGE_NAME = "spring-hello-world"
    IMAGE_TAG = "latest"
    LOCAL_REGISTRY = "localhost:5000"
    FULL_IMAGE = "${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    DEPLOYMENT_TEMPLATE = "k8s/deployment-template.yaml"
    ACTIVE_COLOR = ""
    NEW_COLOR = ""
  }

  stages {
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Code Scan - SonarQube') {
      steps {
        withSonarQubeEnv('My Sonar Server') {
          sh './gradlew sonar -Dsonar.projectKey=spring-hello-world -Dsonar.host.url=http://localhost:9000 -Dsonar.token=squ_390ef66035245d24bb2e822e478d6ad9641db8bd'
        }
      }
    }

    stage('Lint Code') {
      steps {
        sh './gradlew checkstyleMain'
      }
    }

    stage('Run Tests') {
      steps {
        sh './gradlew test'
      }
    }

    stage('Code Coverage - Jacoco') {
      steps {
        sh './gradlew jacocoTestReport'
      }
    }

    stage('Static Analysis - SpotBugs') {
      steps {
        sh './gradlew spotbugsMain'
      }
    }

    stage('Security Scan - Trivy') {
      steps {
        sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL ${FULL_IMAGE} || true'
      }
    }

    stage('Tag and Push to Local Registry') {
      steps {
        sh 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}'
        sh 'docker push ${FULL_IMAGE}'
      }
    }

    stage('Prepare Blue-Green Deployment') {
      steps {
        script {
          def currentSelector = sh(script: "kubectl get svc hello-world-service -n helloworld -o=jsonpath='{.spec.selector.version}' || echo none", returnStdout: true).trim()
          env.ACTIVE_COLOR = currentSelector ?: "blue"
          env.NEW_COLOR = (env.ACTIVE_COLOR == "blue") ? "green" : "blue"
          echo "Current Active: ${env.ACTIVE_COLOR}, Deploying: ${env.NEW_COLOR}"
          sh "export IMAGE=${FULL_IMAGE} COLOR=${NEW_COLOR} && envsubst < ${DEPLOYMENT_TEMPLATE} > k8s/deployment.yaml"
        }
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh 'kubectl apply -f k8s/deployment.yaml'
        sh 'kubectl rollout status deployment/hello-${NEW_COLOR} -n helloworld --timeout=60s'
      }
    }

    stage('Manual Approval Before Switch') {
      steps {
        input message: "Do you want to switch traffic to ${NEW_COLOR}?", ok: "Yes, Promote"
      }
    }

    stage('Switch Traffic to New Color') {
      steps {
        sh '''
          kubectl patch svc hello-world-service -n helloworld \
            -p '{"spec":{"selector":{"app":"hello-world", "version":"${NEW_COLOR}"}}}'
        '''
      }
    }

    stage('Cleanup Old Deployment') {
      steps {
        script {
          def OLD_COLOR = (env.NEW_COLOR == "blue") ? "green" : "blue"
          sh "kubectl delete deployment hello-${OLD_COLOR} -n helloworld || true"
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'build/reports/**/*.html', allowEmptyArchive: true
      junit 'build/test-results/test/*.xml'
      publishHTML(target: [reportDir: 'build/reports/checkstyle', reportFiles: 'checkstyle.html', reportName: 'Checkstyle Report'])
      publishHTML(target: [reportDir: 'build/reports/tests/test', reportFiles: 'index.html', reportName: 'Test Report'])
      publishHTML(target: [reportDir: 'build/reports/jacoco/test/html', reportFiles: 'index.html', reportName: 'Jacoco Coverage Report'])
      publishHTML(target: [reportDir: 'build/reports/spotbugs/main', reportFiles: 'spotbugs.html', reportName: 'SpotBugs Report'])
    }
    failure {
      echo '❌ Build or Deployment failed.'
    }
    success {
      echo '✅ App deployed using Blue-Green Strategy!'
    }
  }
}
