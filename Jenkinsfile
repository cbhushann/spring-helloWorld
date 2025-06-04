pipeline {
    agent any

    environment {
        ACR_NAME = 'kk1registry'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = 'hello-world'
        IMAGE_TAG = 'latest'
        AKS_CLUSTER = 'kk1'
        AKS_RESOURCE_GROUP = 'kk1_group' // Replace with your resource group
        YAML_PATH = 'deployment.yaml'
        NAMESPACE = 'helloworld'
        DEPLOYMENT_NAME = 'hello-world-deployment'
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'gradle:8.14.0-jdk21-alpine'
                    reuseNode true
                }
            }
            steps {
                sh 'gradle -g gradle-user-home --version'
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        stage('Login to Azure') {
            steps {
                withCredentials([azureServicePrincipal('AZURE_CREDENTIALS_ID')]) {
                    sh '''
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                        az acr login --name $ACR_NAME
                    '''
                }
            }
        }
        stage('Push to ACR') {
            steps {
                sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        stage('AKS Credentials') {
            steps {
                sh "az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER} --overwrite-existing"
            }
        }
        stage('Deploy to AKS') {
            steps {
                sh "kubectl apply -f ${YAML_PATH} -n ${NAMESPACE}"
                sh "kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=5m"
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment Succeeded!'
        }
        failure {
            echo 'Deployment Failed!'
        }
    }
}