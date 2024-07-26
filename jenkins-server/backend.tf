terraform {
  backend "s3" {
    bucket = "cicd-blockchain-bucket"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"

  }
}