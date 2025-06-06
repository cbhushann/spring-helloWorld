pipeline {
  agent any

  stages {
    stage('Build Docker Image') {
      steps {
        sh 'eval $(minikube docker-env) && docker build -t spring-hello-world:latest .'
      }
    }

    stage('Deploy to Minikube') {
      steps {
        sh '''
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
        '''
      }
    }
  }

  post {
    failure {
      echo '❌ Deployment failed.'
    }
    success {
      echo '✅ Deployment succeeded on Minikube.'
    }
  }
}
