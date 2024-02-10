terraform {
  backend "s3" {
    bucket         = "myterraform-bucket-state-yoon-t"
    key            = "aws_eks/eks/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "admin_user"
    dynamodb_table = "myTerraform-bucket-lock-yoon-t"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "admin_user"
}


module "aws_eks_cluster" {
  source              = "../../module/eks"
  cluster_name        = "my-eks"
  cluster_version     = "1.28"
  cluster_admin       = data.aws_iam_user.EKS_Admin_ID.user_id
  vpc_id              = data.terraform_remote_state.remote_vpc.outputs.vpc_id
  vpc_private_subnets = data.terraform_remote_state.remote_vpc.outputs.vpc_private_subnets
}

resource "aws_ec2_tag" "private_subnet_tag" {
  for_each    = toset(data.terraform_remote_state.remote_vpc.outputs.vpc_private_subnets) #(module.vpc.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

// Public Subnet Tag ( AWS Load Balancer Controller Tag / internet-facing )
resource "aws_ec2_tag" "public_subnet_tag" {
  for_each    = toset(data.terraform_remote_state.remote_vpc.outputs.vpc_public_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}