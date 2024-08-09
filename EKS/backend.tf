# 
# Create S3 bucket for eks cluster to save TF state
#


terraform {
  backend "s3" {
    bucket = "terraform-eks-cicd-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}