pipeline {
    parameters {
        choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy the eks cluster.')
        string(name: 'credential', defaultValue : 'jenkins', description: "Jenkins credential that provides the AWS access key and secret.")
        string(name: 'region', defaultValue : 'us-east-1', description: "AWS region.")
    }
    
    agent any

    environment {
        // Set path to workspace bin dir
        PATH = "${env.WORKSPACE}/bin:${env.PATH}"
        // Workspace kube config so we don't affect other Jenkins jobs
        KUBECONFIG = "${env.WORKSPACE}/.kube/config"
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Check out the source code from the specified Git repository and branch
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Sunjustine/cicd-pipeline-for-smart-contracts.git']])
                }
            }
        }
        
        stage('TF plan') {
            when {
                expression { params.action == 'create' }
            }
            
            steps {
                script {
                    // Navigate to the EKS directory
                    dir('EKS') {
                        // Use AWS credentials to run Terraform commands
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: 'my-eks-cluster', 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh """
                            terraform init;  // Initialize Terraform
                            terraform fmt;  // Format Terraform files
                            terraform validate;  // Validate Terraform configuration
                            terraform plan -out=./output_plan_file;  // Create a Terraform plan
                            """
                        }
                    }
                }
            }
        }    
        
        stage('TF apply') {
            when {
                expression { params.action == 'create' }
            }
            
            steps {
                script {
                    // Navigate to the EKS directory
                    dir('EKS') {
                        // Use AWS credentials to apply the Terraform plan
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: 'my-eks-cluster', 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform apply --auto-approve "./output_plan_file"'  // Apply the Terraform plan
                        }
                    }
                }
            }
        }

        stage('deploy_data') {
            when {
                expression { params.action == 'create' }
            }

            steps {
                script {
                    // Navigate to the deployment directory
                    dir('EKS/deploy-eks-cluster-data') {
                        // Use AWS credentials to update kubeconfig and perform Docker/Kubernetes actions
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: 'my-eks-cluster', 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh """
                            aws eks update-kubeconfig --name ${params.cluster} --region ${params.region};  // Update kubeconfig
                            // Build the Docker image
                            docker build -t sunjustine/ganache:latest --target ganache .
                            docker build -t sunjustine/truffle:latest --target truffle .

                            docker push sunjustine/ganache:latest
                            docker push sunjustine/truffle:latest

                            
                            // Push the Docker image to the registry
                            docker.withRegistry("https://${env.DOCKER_REGISTRY}", 'docker-credentials-id') {
                                docker.image("${env.DOCKER_IMAGE_NAME}:${env.DOCKER_TAG}").push()
                            }

                            // Apply the Kubernetes deployment files
                            kubectl apply -f ganache-deployment.yml
                            kubectl apply -f truffle-deployment.yml
                            """
                        }
                    }
                }
            }
        }

        stage('TF destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            
            steps {
                script {
                    // Navigate to the EKS directory
                    dir('EKS') {
                        // Use AWS credentials to destroy the Terraform-managed infrastructure and clean up
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: 'my-eks-cluster', 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh """
                            aws eks update-kubeconfig --name ${params.cluster} --region ${params.region};  // Update kubeconfig
                            kubectl delete deployment --all --namespace=default;  // Delete all Kubernetes deployments
                            terraform destroy --auto-approve "./output_plan_file";  // Destroy the Terraform-managed infrastructure
                            rm -rvf ./output_plan_file;  // Remove the Terraform plan file
                            """
                        }
                    }
                }
            }
        }
    }
}
