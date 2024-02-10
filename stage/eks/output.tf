output "eks_sg_id" {
  value = module.aws_eks_cluster.eks_sg_id
}

output "eks_cluster_oidc_arn" {
  value       = module.aws_eks_cluster.eks_cluster_oidc_arn
  description = "eks_cluster_oidc"
}

output "eks_cluster_oidc" {
  value       = module.aws_eks_cluster.eks_cluster_oidc
  description = "eks_cluster_oidc"
}

