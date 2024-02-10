module "database_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = var.ec2_name
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.EC2-Key.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = element(var.vpc_database_subnets, 1)

  tags = {
    Terraform   = "true"
  }
}

data "aws_key_pair" "EC2-Key" {
  key_name = "EC2-key"
}