terraform {
  backend "s3" {
    bucket         = "myterraform-bucket-state-yoon-t"
    key            = "aws_eks/ec2/terraform.tfstate"
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


module "bastion_instance" {
  source = "../../module/ec2/bastion"
  vpc_id = data.terraform_remote_state.remote_vpc.outputs.vpc_id
  ami = "ami-086cae3329a3f7d75"
  vpc_public_subnets = data.terraform_remote_state.remote_vpc.outputs.vpc_public_subnets
  ec2_name = "bastion"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.bastion_sg.id, data.terraform_remote_state.remote_eks.outputs.eks_sg_id, aws_security_group.database_sg.id ]
}
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "security group"
  vpc_id      = data.terraform_remote_state.remote_vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic"
  }

  tags = {
    Name = "bastion_sg"
  }
}

module "database_instance" {
  source = "../../module/ec2/database"
  vpc_id                = data.terraform_remote_state.remote_vpc.outputs.vpc_id
  ami = "ami-086cae3329a3f7d75"
  vpc_database_subnets  = data.terraform_remote_state.remote_vpc.outputs.vpc_database_subnets
  ec2_name              = "database"
  instance_type         = "t2.micro"
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Database security group"
  vpc_id      = data.terraform_remote_state.remote_vpc.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic"
  }

  tags = {
    Name = "database_sg"
  }
}





