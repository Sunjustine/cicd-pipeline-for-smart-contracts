terraform {
  backend "s3" {
    bucket = "terraform-cicd-eks-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}