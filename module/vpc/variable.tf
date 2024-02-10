variable "vpc_name" {
  description = "vpc name"
  type = string
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type = string
}

variable "vpc_azs" {
  description = "vpc azs"
  type = list(string)
}

variable "vpc_public_subnets" {
  description = "vpc public_subnets"
  type = list(string)
}

variable "vpc_private_subnets" {
  description = "vpc private_subnets"
  type = list(string)
}

variable "vpc_database_subnets" {
  description = "vpc database_subnets"
  type = list(string)
}



