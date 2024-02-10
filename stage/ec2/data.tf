data "terraform_remote_state" "remote_vpc" {
  backend = "s3"
  config = {
    bucket = "myterraform-bucket-state-yoon-t"
    key = "aws_eks/vpc/terraform.tfstate"
    profile = "admin_user"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "remote_eks" {
  backend = "s3"
  config = {
    bucket = "myterraform-bucket-state-yoon-t"
    key = "aws_eks/eks/terraform.tfstate"
    profile = "admin_user"
    region = "ap-northeast-2"
  }
}

