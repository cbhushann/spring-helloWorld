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
    agent {
              label 'docker-enabled'
    }

    environment {
        // Use build number for unique image tags instead of 'latest'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${imageName}:${IMAGE_TAG}"
        // Ensure gcloud doesn't prompt for input
        CLOUDSDK_CORE_DISABLE_PROMPTS = '1'
        GCLOUD_INSTALL_DIR = "$HOME/google-cloud-sdk"
        GCLOUD_PATH = "${GCLOUD_INSTALL_DIR}/bin"
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

        // --- NEW STAGE TO INSTALL GCLOUD ---
        stage('Install gcloud') {
            steps {
                echo "Installing Google Cloud SDK to ${env.GCLOUD_INSTALL_DIR}..."
                sh '''
                    set -e
                    echo "Downloading Google Cloud SDK..."
                    curl -fLO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-465.0.0-linux-x86_64.tar.gz

                    echo "--- Content of downloaded file (first few bytes): ---"
                    head -c 256 google-cloud-sdk-465.0.0-linux-x86_64.tar.gz || true
                    echo "--- End of file content ---"

                    echo "Extracting SDK to $HOME..."
                    tar -xzf google-cloud-sdk-465.0.0-linux-x86_64.tar.gz -C $HOME

                    echo "Verifying gcloud installation..."
                    $HOME/google-cloud-sdk/bin/gcloud --version

                    echo "Cleaning up archive..."
                    rm google-cloud-sdk-465.0.0-linux-x86_64.tar.gz
                '''
            }
        }
        // --- END NEW STAGE ---

        stage('Build and Push Image with Kaniko') {
            steps {
                container('kaniko') {
                    withCredentials([file(credentialsId: googleCredentialsId, variable: 'GCLOUD_KEY_FILE')]) {
                        sh '''
                            echo "Setting up Kaniko secret..."
                            mkdir -p /kaniko/.docker
                            cat $GCLOUD_KEY_FILE > /kaniko/.docker/config.json

                            echo "Building and pushing image with Kaniko..."
                            /kaniko/executor \
                              --context `pwd` \
                              --dockerfile `pwd`/Dockerfile \
                              --destination=${FULL_IMAGE_NAME} \
                              --verbosity=info
                        '''
                    }
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