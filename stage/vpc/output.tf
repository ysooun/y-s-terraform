output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID Output"
}

output "vpc_private_subnets" {
  value       = module.vpc.vpc_private_subnets
  description = "Private_Subnets_Cidr_Blocks Output"
}

output "vpc_public_subnets" {
  value       = module.vpc.vpc_public_subnets
  description = "Private_Subnets_Cidr_Blocks Output"
}

output "vpc_database_subnets" {
  value       = module.vpc.vpc_database_subnets
  description = "Private_Subnets_Cidr_Blocks Output"
}