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
    from_port   = 3306  # 예시로 MySQL 포트를 사용했습니다. 필요에 따라 포트를 수정하세요.
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL"
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


/* aws cli 다운로드
sudo apt-get remove awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
export PATH=/usr/local/bin:$PATH
source ~/.bashrc
aws --version
*/

/* kunectl 다운로드
curl -LO https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.13/2023-05-11/bin/linux/amd64/kubectl
chmod +x kubectl
mkdir -p $HOME/bin && mv ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
kubectl version --short --client
*/

# aws configure --profile admin_user		##admin_user(administratorAccess)
# aws configure list --profile admin_user
# aws --profile admin_user eks --region ap-northeast-2 update-kubeconfig --name my-eks --alias my-eks
# kubectl config get-contexts
# kubectl config use-context my-eks

/*
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
*/


# aws eks create-addon --cluster-name my-eks --addon-name aws-ebs-csi-driver --service-account-role-arn arn:aws:iam::228306359692:role/ebs-csi-irsa_role


