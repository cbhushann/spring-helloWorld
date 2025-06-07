pipeline {
  agent any

  environment {
    IMAGE_NAME = "spring-hello-world"
    IMAGE_TAG = "latest"
    LOCAL_REGISTRY = "localhost:5000"
    FULL_IMAGE = "${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
  }

  stages {
    stage('Build Docker Image') {
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        """
      }
    }

    stage('Code Scan - SonarQube') {
      steps {
        sh './gradlew sonarqube -Dsonar.projectKey=spring-hello-world -Dsonar.host.url=http://localhost:9000 -Dsonar.login=squ_70ff1aa72a0bfca8f6436f7aa36c30ae5890300a'
      }
    }

    stage('Lint Code') {
      steps {
        sh './gradlew checkstyleMain'
      }
    }

    stage('Tag and Push to Local Registry') {
      steps {
        sh """
          docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}
          docker push ${FULL_IMAGE}
        """
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh """
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
        """
      }
    }
  }

  post {
    failure {
      echo '❌ Build or Deployment failed.'
    }
    success {
      echo '✅ App deployed to Minikube successfully.'
    }
  }
}
