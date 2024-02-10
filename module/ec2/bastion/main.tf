# EKS Cluster SG : data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id 

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = var.ec2_name
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.EC2-Key.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = element(var.vpc_public_subnets, 1)

  tags = {
    Terraform   = "true"
  }
}

# BastionHost EIP
resource "aws_eip" "bastion_eip" {
  instance = module.ec2_instance.id
  tags = {
    Name = "BastionHost_EIP"
  }
}

data "aws_key_pair" "EC2-Key" {
  key_name = "EC2-key"
}
