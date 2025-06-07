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
