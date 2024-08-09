pipeline {
    parameters {
        choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy the EKS cluster.')
        string(name: 'credential', defaultValue: 'jenkins', description: "Jenkins credential that provides the AWS access key and secret.")
        string(name: 'region', defaultValue: 'us-east-1', description: "AWS region.")
        string(name: 'registry', defaultValue: 'YourDockerhubAccount/YourRepository', description: 'Docker registry for pushing images.')
        string(name: 'docker_credentials', defaultValue: 'docker_credentials', description: "Jenkins credentials for Docker authentication.")
        string(name: 'cluster', defaultValue: 'my-eks-cluster', description: 'The name of the EKS cluster.')
    }

    agent any

    environment {
        PATH = "${env.WORKSPACE}/bin:${env.PATH}"
        KUBECONFIG = "${env.WORKSPACE}/.kube/config"
    }

    stages {
        stage('Parameter Validation') {
            steps {
                script {
                    if (params.registry == 'YourDockerhubAccount/YourRepository') {
                        error "Please replace the 'registry' parameter with a valid Docker registry."
                    }
                }
            }
        }

        stage('Checkout SCM') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Sunjustine/cicd-pipeline-for-smart-contracts.git']])
            }
        }

        stage('Docker Build and Push') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dir('truffle-project') {
                        withDockerRegistry(credentialsId: params.docker_credentials) {
                            def images = [
                                'ganache': 'ganache:latest',
                                'truffle': 'truffle:latest'
                            ]

                            images.each { dir, image ->
                                sh "docker build --target ${dir} -t ${image} ."

                                sh "docker push ${params.registry}/${image}"
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Initialization') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dir('EKS') {
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: params.credential, 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform init'
                            sh 'terraform fmt'
                            sh 'terraform validate'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dir('EKS') {
                        withCredentials([aws(
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: params.credential, 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'terraform plan -out=./file.tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    try {
                        dir('EKS') {
                            withCredentials([aws(
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                credentialsId: params.credential, 
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                                sh 'terraform apply --auto-approve "./file.tfplan"'
                            }
                        }
                    } catch (Exception e) {
                        error "Terraform apply failed: ${e.message}"
                    }
                }
            }
        }

        stage('Update Kubernetes Config') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    updateKubeConfig(params.cluster, params.region)
                }
            }
        }


        stage('Kubernetes Deployment') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    dir('truffle-project/kube-deploys') {
                        def k8sFiles = [
                            'ganache-deployment.yml',
                            'ganache-service.yml',
                            'truffle-deployment.yml'
                        ]

                        k8sFiles.each { file ->
                            sh "kubectl apply -f ${file}"
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.action == 'destroy' } }
            steps {
                script {
                    try {
                        dir('EKS') {
                            withCredentials([aws(
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                credentialsId: params.credential, 
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                                updateKubeConfig(params.cluster, params.region)
                                sh 'kubectl delete deployment --all --namespace=default'
                                sh 'kubectl delete service --all --namespace=default'
                                sh 'terraform destroy --auto-approve'
                            }
                        }
                    } catch (Exception e) {
                        error "Terraform destroy failed: ${e.message}"
                    }
                }
            }
        }
    }
}

def updateKubeConfig(clusterName, region) {
    sh "aws eks update-kubeconfig --name ${clusterName} --region ${region}"
}
