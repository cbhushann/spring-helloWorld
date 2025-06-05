pipeline {
  agent any

  environment {
    AZURE_REGISTRY = "kk1registry"
    ACR_TASK_NAME = "springhellotask"   // make sure this task exists
    IMAGE_TAG = "latest"
    IMAGE_NAME = "spring-hello-world"
    FULL_IMAGE = "${AZURE_REGISTRY}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
  }

  stages {
    stage('Trigger ACR Task Build') {
      steps {
        sh """
          az acr task run \
            --name ${ACR_TASK_NAME} \
            --registry ${AZURE_REGISTRY}
        """
      }
    }

    stage('Deploy to AKS') {
      steps {
        sh """
          kubectl set image deployment/hello-world-deployment hello-world-container=${FULL_IMAGE} -n helloworld
          kubectl rollout status deployment/hello-world-deployment -n helloworld
        """
      }
    }
  }

  post {
    failure {
      echo '❌ Deployment failed.'
    }
    success {
      echo '✅ Deployment succeeded.'
    }
  }
}