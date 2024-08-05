#!/bin/bash

# Function to create the Terraform infrastructure
create_infra() {
    terraform fmt
    terraform validate
    terraform plan -out=./plan.tfplan
    terraform apply --auto-approve "./plan.tfplan"
    rm -rvf ./output-file
}

# Function to destroy the Terraform infrastructure
destroy_infra() {
    terraform destroy --auto-approve
}

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {create|destroy}"
    exit 1
fi

# Execute the appropriate function based on the argument
case "$1" in
    create)
        create_infra
        ;;
    destroy)
        destroy_infra
        ;;
    *)
        echo "Usage: $0 {create|destroy}"
        exit 1
        ;;
esac