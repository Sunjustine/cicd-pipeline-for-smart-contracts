#!/bin/bash

# This script is needed to install Jenkins server
# on our EC2 instance

# Update packages
sudo apt-get update -y;

sudo apt install -y awscli;

# Docker installation
sudo apt install -y docker.io;

# Install java openjdk 11
sudo apt install openjdk-17-jdk -y;


# Check if Java is installed
if java --version &> /dev/null
then
    # Get the Java version
    java_version=$(java --version 2>&1 | awk -F[\"_] 'NR==1{print $2}')
    echo "Java version: $java_version"

    # Continue with the rest of the script
    # Add your code here

else
    echo "ERROR: Java is not installed. Exiting."
    exit 1
fi


# Let's add the repository key to your system:
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg;

# Next, let’s append the Debian package repository 
# address to the server’s sources.list:
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list';

# After both commands have been entered, run apt 
# update so that apt will use the new repository.
sudo apt update -y;

# Finally, install Jenkins and its dependencies:
sudo apt install jenkins -y;

# now that Jenkins is installed, start it by using 
# systemctl:
sudo systemctl start jenkins.service;

# Enable jenkins service
sudo systemctl enable jenkins.service;

# Run the command to get Jenkins version
versionOutput=$(jenkins --version 2>&1)

# Check if the command was successful and the output is not empty
if [[ $? -eq 0 && ! -z "$versionOutput" ]]; then
    echo "Jenkins version: $versionOutput"
    # Continue with the next steps
else
    echo "ERROR: Jenkins version command returned empty or an error occurred. Exiting."
    exit 1
fi

# Then install git
sudo apt install -y git;

# Then install terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg;

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list;

sudo apt update -y && sudo apt install terraform -y;

# Then install kubectl


# Download the latest release with the command:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";

# Download the kubectl checksum file:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256";

# Validate the kubectl binary against the checksum file:
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Run the command to get kubectl version
versionOutput=$(kubectl version --client --short 2>&1)

# Check if the command was successful and the output is not empty
if [[ $? -eq 0 && ! -z "$versionOutput" ]]; then
    echo "kubectl version: $versionOutput"
    # Continue with the next steps
else
    echo "ERROR: kubectl version command returned empty or an error occurred. Exiting."
    exit 1
fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh;

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash;

source ~/.bashrc

nvm install v18.20.4

node -v