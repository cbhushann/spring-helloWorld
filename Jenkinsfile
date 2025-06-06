pipeline {
  agent any

  stages {
    stage('Build inside Minikube Docker') {
      steps {
        script {
          def dockerEnv = sh(script: "minikube docker-env", returnStdout: true).trim()
          sh """
            ${dockerEnv}
            docker build -t spring-hello-world:latest .
          """
        }
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh 'kubectl apply -f k8s/deployment.yaml'
        sh 'kubectl apply -f k8s/service.yaml'
      }
    }
  }
}
