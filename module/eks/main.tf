provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.vpc_private_subnets

  # OIDC(OpenID Connect) 구성 
  enable_irsa = true

  # EKS Worker Node 정의 ( ManagedNode방식 / Launch Template 자동 구성 )
  eks_managed_node_groups = {
    initial = {
      instance_types         = ["t3.small"]
      create_security_group  = false
      create_launch_template = false # Required Option 
      launch_template_name   = ""    # Required Option

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  # node_security_group_additional_rules = {
  #   ingress_allow_access_from_control_plane = {
  #     type                          = "ingress"
  #     protocol                      = "tcp"
  #     from_port                     = 9443
  #     to_port                       = 9443
  #     source_cluster_security_group = true
  #     description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
  #   }
  # }

  # K8s ConfigMap Object "aws_auth" 구성
  manage_aws_auth_configmap = true
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${var.cluster_admin}:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]
}




# module "vpc_cni_irsa_role" { 
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name             = "eks-vpc-cni-irsa-role"
#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }

#   tags = {
#     CreatedBy = "Terraform"
#   }
# }



module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "eks-lb-controller-irsa-role"
  attach_load_balancer_controller_policy = true 

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    CreatedBy = "Terraform"
  }
}

module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                     = "eks-externaldns-irsa-role"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z0848139JQFD9W34V8R7"]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = {
    CreatedBy = "Terraform"
  }
}

# module "iam_autoscaler_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name   = "eks-autoscaler-irsa-role"
#   attach_cluster_autoscaler_policy = true

#   cluster_autoscaler_cluster_ids = [module.eks.cluster_id]

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cluster-autoscaler"]
#     }
#   }

#   tags = {
#     CreatedBy = "Terraform"
#     Role      = "autoscaler"
#   }
# }

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs-csi-irsa_role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}


# //jenkins iras
# resource "aws_iam_policy" "jenkins_secrets_manager_policy" {
#   name        = "jenkins-secrets-manager-policy"
#   description = "Policy for Jenkins to access AWS Secrets Manager"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid      = "AllowJenkinsToGetSecretValues",
#         Effect   = "Allow",
#         Action   = "secretsmanager:GetSecretValue",
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowJenkinsToListSecrets",
#         Effect = "Allow",
#         Action = "secretsmanager:ListSecrets",
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowJenkinsToManageEC2",
#         Effect = "Allow",
#         Action = [
#           "ec2:*"
#         ],
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowJenkinsToAccessS3",
#         Effect = "Allow",
#         Action = [
#           "s3:*"
#         ],
#         Resource = "*"
#       },
#       {
#         Sid    = "AllowJenkinsToUseEBS",
#         Effect = "Allow",
#         Action = [
#           "ec2:AttachVolume",
#           "ec2:DetachVolume",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeVolumeStatus",
#           "ec2:CreateVolume",
#           "ec2:DeleteVolume"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "jenkins_irsa_role" {
#   name = "jenkins-irsa-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = module.eks.oidc_provider_arn
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals = {
#             "${module.eks.oidc_provider_arn}:sub" = "system:serviceaccount:kube-system:jenkins-service-account"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "jenkins_secrets_manager_attachment" {
#   role       = aws_iam_role.jenkins_irsa_role.name
#   policy_arn = aws_iam_policy.jenkins_secrets_manager_policy.arn
# }




# resource "kubernetes_service_account" "aws-load-balancer-controller" {
#   metadata {
#     name        = "aws-load-balancer-controller"
#     namespace   = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.load_balancer_controller_irsa_role.iam_role_arn  
#     }

#     labels = {
#       "app.kubernetes.io/component" = "controller"
#       "app.kubernetes.io/name" = "aws-load-balancer-controller"
#     }

#   }

#   depends_on = [module.load_balancer_controller_irsa_role]
# }

# resource "kubernetes_service_account" "external-dns" {
#   metadata {
#     name        = "external-dns"
#     namespace   = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
#     }
#   }

#   depends_on = [module.external_dns_irsa_role]
# }

# resource "kubernetes_service_account" "autoscaler" {
#   metadata {
#     name        = "cluster-autoscaler"
#     namespace   = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.iam_autoscaler_irsa_role.iam_role_arn
#     }
#   }

#   depends_on = [module.iam_autoscaler_irsa_role]
# }