pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: azcli
    image: mcr.microsoft.com/azure-cli
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
"""
    }
  }

  environment {
    AZ_CLIENT_ID = credentials('AZ_CLIENT_ID')
    AZ_CLIENT_SECRET = credentials('AZ_CLIENT_SECRET')
    AZ_TENANT_ID = credentials('AZ_TENANT_ID')
    AZ_SUBSCRIPTION_ID = credentials('AZ_SUBSCRIPTION_ID')
    AZURE_REGISTRY = "kk1registry"
    ACR_TASK_NAME = "springhellotask"
    IMAGE_TAG = "latest"
    IMAGE_NAME = "spring-hello-world"
    FULL_IMAGE = "${AZURE_REGISTRY}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
  }

  stages {
    stage('Trigger ACR Task Build') {
      steps {
        container('azcli') {
          sh """
            az acr task run \
              --name ${ACR_TASK_NAME} \
              --registry ${AZURE_REGISTRY}
          """
        }
      }
    }

    stage('Deploy to AKS') {
      steps {
        container('kubectl') {
          sh """
            kubectl set image deployment/hello-world-deployment hello-world-container=${FULL_IMAGE} -n helloworld
          """
        }
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