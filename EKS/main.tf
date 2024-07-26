# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.azs.names

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kuberenetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kuberenetes.io/role/internal-elb"     = "1"
  }

}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_groups = {
    node = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = ["t2.small"]
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = false



  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
