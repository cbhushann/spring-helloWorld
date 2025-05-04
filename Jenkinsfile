// Jenkinsfile (Declarative Pipeline)

// --- Configuration ---
def appName = 'hello-world'
def deploymentName = "${appName}-deployment"
def serviceName = "${appName}-service" // Assuming your service is named this
def dockerRegistry = 'us-central1-docker.pkg.dev'
def gcpProject = 'onyx-codex-274605' // Replace with your GCP Project ID
def artifactRepo = 'hello-world-repo'
def imageName = "${dockerRegistry}/${gcpProject}/${artifactRepo}/${appName}"
def deploymentFile = 'deployment.yaml'
def serviceFile = 'service.yaml' // Adjust if your service file has a different name (e.g., k8s-svc.yaml)
def googleCredentialsId = 'google-artifact-registry-key' // Jenkins Credential ID for GAR JSON key
def kubeconfigCredentialsId = 'kubeconfig-credentials' // Jenkins Credential ID for kubeconfig
def kubernetesNamespace = 'default' // Change if deploying to a different namespace
// def mavenToolName = 'Maven4'
// --- End Configuration ---

pipeline {
    agent any // Or specify a label for an agent with mvn, docker, gcloud, kubectl

    environment {
        // Use build number for unique image tags instead of 'latest'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${imageName}:${IMAGE_TAG}"
        // Ensure gcloud doesn't prompt for input
        CLOUDSDK_CORE_DISABLE_PROMPTS = '1'
        //MVN_HOME = tool mavenToolName
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building Spring Boot application...'
                // Assuming Maven is used based on pom.xml
                // Use a Maven tool configured in Jenkins or ensure mvn is in PATH
//                 sh "${MVN_HOME}/bin/mvn clean package -DskipTests"
                sh 'chmod +x gradlew'
                sh './gradlew build -x test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.FULL_IMAGE_NAME}"
                // Authenticate Docker with Google Artifact Registry
                withCredentials([file(credentialsId: googleCredentialsId, variable: 'GCLOUD_KEY_FILE')]) {
                    sh "gcloud auth activate-service-account --key-file=${GCLOUD_KEY_FILE}"
                    sh "gcloud auth configure-docker ${dockerRegistry} --quiet"
                }
                // Build the image
                sh "docker build -t ${env.FULL_IMAGE_NAME} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image: ${env.FULL_IMAGE_NAME}"
                // Authentication should still be valid from the build stage
                sh "docker push ${env.FULL_IMAGE_NAME}"
            }
            post {
                always {
                    // Clean up local docker image after push (optional)
                    sh "docker rmi ${env.FULL_IMAGE_NAME} || true"
                    // Revoke gcloud credentials (good practice)
                    sh "gcloud auth revoke --all || true"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying ${deploymentName} and ${serviceName} to Kubernetes..."
                withKubeConfig([credentialsId: kubeconfigCredentialsId]) {
                    // Apply the service definition first (or ensure it exists)
                    // Adjust filename if necessary
                    sh "kubectl apply -f ${serviceFile} --namespace ${kubernetesNamespace}"

                    // Apply the deployment definition
                    // This ensures the base deployment object exists with the correct serviceAccountName etc.
                    sh "kubectl apply -f ${deploymentFile} --namespace ${kubernetesNamespace}"

                    // Update the deployment to use the specific image tag we just built and pushed
                    // This is often preferred over modifying the yaml file directly in the workspace
                    sh "kubectl set image deployment/${deploymentName} hello-world-container=${env.FULL_IMAGE_NAME} --namespace ${kubernetesNamespace} --record"

                    // Optional: Wait for deployment rollout to complete
                    sh "kubectl rollout status deployment/${deploymentName} --namespace ${kubernetesNamespace} --timeout=120s"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            // Add any cleanup steps here if needed
            cleanWs() // Clean up Jenkins workspace
        }
        success {
            echo 'Deployment Successful!'
            // Add notifications (Slack, Email) here
        }
        failure {
            echo 'Deployment Failed!'
            // Add notifications (Slack, Email) here
        }
    }
}