variable "vpc_cidr" {
  description = "VPC CRDR"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR"
  type        = list(string)
}

# variable "vpc_id" {
#   description = "value"
#   type = string
# }

variable "instance_type" {
  description = "Instance type"
  type        = string
}