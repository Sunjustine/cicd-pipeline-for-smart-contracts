variable "vpc_cidr" {
  description = "VPC CRDR"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subnets CIDR"
  type        = list(string)
}