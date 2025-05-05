// Jenkinsfile

pipeline {
    // Define an agent that runs inside a Kubernetes pod
    agent {
        kubernetes {
            // Define the Pod template
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: google/cloud-sdk:slim
    command:
    - cat
    tty: true
'''
            // Optional: Specify the cloud configuration if you have multiple Kubernetes clouds configured in Jenkins
            // cloud 'kubernetes'
        }
    }

    environment {
        // Define environment variables
        NAMESPACE = 'default' // CHANGE if deploying to a different namespace
        DEPLOYMENT_NAME = 'hello-world-deployment' // Matches metadata.name in deployment.yaml
        YAML_PATH = 'deployment.yaml' // Path to the deployment file in the workspace
    }

    stages {
        stage('Checkout') {
            steps {
                // Get the source code from SCM
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Run kubectl commands inside the specified container
                container('kubectl') {
                    script {
                        echo "Applying Kubernetes deployment manifest ${env.YAML_PATH} to namespace ${env.NAMESPACE}..."
                        // Apply the deployment configuration
                        // Kubectl should automatically use the service account credentials
                        // provided by the Jenkins Kubernetes plugin / Workload Identity
                        sh "kubectl apply -f ${env.YAML_PATH} -n ${env.NAMESPACE}"

                        // Optional: Wait for the rollout to complete and check status
                        echo "Waiting for deployment ${env.DEPLOYMENT_NAME} rollout to complete..."
                        sh "kubectl rollout status deployment/${env.DEPLOYMENT_NAME} -n ${env.NAMESPACE} --timeout=5m" // 5 minute timeout

                        echo "Deployment successful!"
                    }
                }
            }
        }

        // Optional: Add more stages for testing, cleanup, notifications etc.
        /*
        stage('Verify Service') {
            steps {
                container('kubectl') {
                    // Add steps to check if the service is accessible, pods are healthy etc.
                    echo "Verifying deployment..."
                    sh "kubectl get pods -l app=hello-world -n ${env.NAMESPACE}"
                    // Add curl commands or other checks if a Service is also defined
                }
            }
        }
        */
    }

    post {
        // Actions to take after the pipeline runs, regardless of status
        always {
            echo 'Pipeline finished.'
            // Clean up workspace?
            // deleteDir()
        }
        success {
            echo 'Deployment Succeeded!'
            // Send notification?
        }
        failure {
            echo 'Deployment Failed!'
            // Send notification? Rollback?
        }
    }
}