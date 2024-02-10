variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "vpc_private_subnets" {
  description = "vpc_private_subnets"
  type = list(string)
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
}

variable "cluster_admin" {
  description = "Cluster Admin IAM User Account ID"
  type        = string
}
