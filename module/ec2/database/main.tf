module "database_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = var.ec2_name
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = element(var.vpc_database_subnets, 1)

  tags = {
    Terraform   = "true"
  }
}
