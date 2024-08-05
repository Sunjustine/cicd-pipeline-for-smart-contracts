variable "vpc_cidr" {
  description = "VPC CRDR"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "aws_region" {
  description = "aws default region"
  type        = string
}