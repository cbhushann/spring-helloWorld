pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: kk1registry.azurecr.io/jenkins-agent:gradle-docker-azure
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
    }
  }

  environment {
    IMAGE_NAME = "kk1registry.azurecr.io/spring-hello-world:latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Docker Build & Push') {
      steps {
        sh 'docker version'
        sh 'docker build -t $IMAGE_NAME .'
        sh 'docker push $IMAGE_NAME'
      }
    }

    stage('Deploy to AKS') {
      steps {
        sh 'kubectl version --client'
        sh 'kubectl set image deployment/hello-deployment hello=$IMAGE_NAME -n helloworld'
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
