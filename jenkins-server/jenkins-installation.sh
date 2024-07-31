#!/bin/bash

# This script is needed to install Jenkins server
# on our EC2 instance

# Create or clear the log file
: > ./output.log

# Function to log output of commands
log_command() {
    "$@" >> ./output.log 2>&1
}

# Update packages
log_command sudo apt-get update -y

# Install java openjdk 11
log_command sudo apt install openjdk-11-jdk -y

# Check if Java is installed
if java --version &> ./output.log
then
    # Get the Java version
    java_version=$(java --version 2>&1 | awk -F[\"_] 'NR==1{print $2}')
    echo "Java version: $java_version" >> ./output.log

    # Continue with the rest of the script
    # Add your code here

else
    echo "ERROR: Java is not installed. Exiting." >> ./output.log
    exit 1
fi

# Let's add the repository key to your system:
log_command wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg

# Next, let’s append the Debian package repository 
# address to the server’s sources.list:
log_command sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# After both commands have been entered, run apt 
# update so that apt will use the new repository.
log_command sudo apt update -y

# Finally, install Jenkins and its dependencies:
log_command sudo apt install jenkins -y

# Now that Jenkins is installed, start it by using 
# systemctl:
log_command sudo systemctl start jenkins.service

# Enable Jenkins service
log_command sudo systemctl enable jenkins.service

# Run the command to get Jenkins version
versionOutput=$(jenkins --version 2>&1)

# Check if the command was successful and the output is not empty
if [[ $? -eq 0 && ! -z "$versionOutput" ]]; then
    echo "Jenkins version: $versionOutput" >> ./output.log
    # Continue with the next steps
else
    echo "ERROR: Jenkins version command returned empty or an error occurred. Exiting." >> ./output.log
    exit 1
fi

# Then install git
log_command sudo apt install -y git

# Then install terraform
log_command wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

log_command echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

log_command sudo apt update -y && sudo apt install terraform -y

# Then install kubectl
log_command curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Download the kubectl checksum file:
log_command curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# Validate the kubectl binary against the checksum file:
log_command echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
log_command sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Run the command to get kubectl version
versionOutput=$(kubectl version --client --short 2>&1)

# Check if the command was successful and the output is not empty
if [[ $? -eq 0 && ! -z "$versionOutput" ]]; then
    echo "kubectl version: $versionOutput" >> ./output.log
    # Continue with the next steps
else
    echo "ERROR: kubectl version command returned empty or an error occurred. Exiting." >> ./output.log
    exit 1
fi

# Install nodejs for truffle
log_command curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh;

log_command curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

log_command source ~/.bashrc

log_command nvm install v18.20.4

node -v