variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "ami" {
  description = "ami"
  type = string
}

variable "vpc_database_subnets" {
  description = "vpc_database_subnets"
  type        = list(string)
}

variable "ec2_name" {
  description = "ec2_name"
  type        = string
}

variable "instance_type" {
  description = "instance_type"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "cluster_security_group_id"
  type        = list(string)
}