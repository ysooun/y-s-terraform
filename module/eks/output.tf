output "eks_sg_id" {
  value = module.eks.cluster_primary_security_group_id 
}

output "eks_cluster_oidc_arn" {
  value = module.eks.oidc_provider_arn
  description = "eks_cluster_oidc"
}

output "eks_cluster_oidc" {
  value = module.eks.oidc_provider
  description = "eks_cluster_oidc"
}
