# CI/CD Deployment for Smart Contracts

This repository provides a complete CI/CD pipeline for deploying and managing Ethereum smart contracts using Truffle and Ganache on a Kubernetes cluster, with Jenkins as the CI/CD tool. The infrastructure for the Jenkins server is created using Terraform in AWS.

## Table of Contents

- [Infrastructure Setup](#infrastructure-setup)
- [Jenkins Pipeline](#jenkins-pipeline)

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
    terraform plan -out=./plan.tfplan
    ```

5. Apply the infrastructure plan to provision the Jenkins server:

    ```sh
    terraform apply ./truffle-project
    ```

You can automate the creation or destruction of the infrastructure using the `jenkins_infrastructure.sh` script with values `destroy` and `create`.

```sh
./jenkins_infrastructure.sh create
./jenkins_infrastructure.sh destroy
```
## Jenkins Pipeline

### Access Jenkins

To begin, navigate to your Jenkins server by entering the following URL in your web browser: 

```sh
http://your-jenkins-server-ip:port
```

Replace `your-jenkins-server-ip` with the actual IP address or hostname of your Jenkins server, and `port` with the correct port number (default is 8080).

### Install Required Packages

Once you've accessed the Jenkins interface, ensure that the following plugins and packages are installed:

- **AWS Credentials**: Allows Jenkins to interact with AWS services.
- **Docker**: Enables Jenkins to build, push, and manage Docker containers.

You can install these plugins from the **Manage Jenkins > Manage Plugins** section.

### Specify Credentials

To allow your Jenkins pipeline to interact with AWS and Docker, you'll need to configure the necessary credentials:

1. **AWS Credentials**:
   - Go to **Manage Jenkins > Manage Credentials**.
   - Add a new **AWS Credential** by providing your AWS Access Key ID and Secret Access Key.

2. **Docker Credentials**:
   - Also under **Manage Jenkins > Manage Credentials**, add a **Docker Credential** with your Docker registry username and password.

Make sure to note the ID of each credential, as you'll need to reference them in your `Jenkinsfile`.

### Create Pipeline from SCM

To set up your pipeline:

1. In Jenkins, click on **New Item**.
2. Select **Pipeline**, give it a name, and click **OK**.
3. Under the **Pipeline** section, find the **Definition** field and select **Pipeline script from SCM**.
4. Configure your SCM (e.g., Git), and point Jenkins to the repository containing your `Jenkinsfile`.

Your pipeline will now be loaded from the specified SCM repository and ready to run.

### Run the Pipeline

When you run the pipeline, you will have the option to specify different actions and variables:

- **Create/Destroy Infrastructure**:
  - You can choose to either create new infrastructure or destroy (clean up) existing infrastructure. This option is useful for managing the lifecycle of your AWS resources.

- **Specify Variables**:
  - During the pipeline run, you can specify the following variables:
    - **AWS Credentials ID**: The ID of the AWS credentials you configured earlier.
    - **Docker Credentials ID**: The ID of the Docker credentials you configured earlier.
    - Any other custom variables you may need for your infrastructure or application deployment.

To customize these options, Jenkins will prompt you when starting the pipeline, or you can modify the `Jenkinsfile` to set defaults or make the options available as parameters.

This flexibility allows you to control how and when your infrastructure is managed and how your pipeline interacts with AWS and Docker services.


