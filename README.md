# CI/CD Deployment for Smart Contracts

This repository provides a complete CI/CD pipeline for deploying and managing Ethereum smart contracts using Truffle and Ganache on a Kubernetes cluster, with Jenkins as the CI/CD tool. The infrastructure for the Jenkins server is created using Terraform in AWS.

## Table of Contents

- [Infrastructure Setup](#infrastructure-setup)
- [Jenkins Pipeline](#jenkins-pipeline)
- [Running the Project](#running-the-project)
- [Cleaning Up](#cleaning-up)

## Infrastructure Setup

### Create Jenkins Server

We use Terraform to set up the infrastructure, which includes initializing a VPC, subnets, and an EC2 instance running Ubuntu 20.04.

1. Navigate to the Terraform directory and initialize Terraform:

    ```sh
    cd terraform
    terraform init
    ```

2. Format the Terraform files:

    ```sh
    terraform fmt
    ```

3. Validate the Terraform configuration:

    ```sh
    terraform validate
    ```

4. Create the infrastructure plan:

    ```sh
    terraform plan -out=./truffle-project
    ```

5. Apply the infrastructure plan to provision the Jenkins server:

    ```sh
    terraform apply ./truffle-project
    ```

You can automate the creation or destruction of the infrastructure using the `jenkins_infrastructure.sh` script with values `destroy` and `create`.

```sh
./jenkins_infrastructure.sh create
./jenkins_infrastructure.sh destroy
