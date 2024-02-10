terraform {
  backend "s3" {
    bucket         = "myterraform-bucket-state-yoon-t"
    key            = "aws_eks/vpc/terraform.tfstate"
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

module "vpc" {
  source = "../../module/vpc"
  vpc_name = "moyur_vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_azs = [ "ap-northeast-2a","ap-northeast-2c" ]
  vpc_public_subnets = [ "10.0.0.0/24","10.0.10.0/24" ]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.11.0/24"]
  vpc_database_subnets = ["10.0.2.0/24", "10.0.12.0/24"]
}
