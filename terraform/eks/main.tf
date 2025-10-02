#############################################
# main.tf  — infra/eks (EKS + VPC + aws-auth)
#############################################

# Locals compartidos (usados por este archivo y por iam_github_oidc.tf)
locals {
  # Si github_oidc_subjects viene vacío, permitimos por defecto la rama main del repo dado
  subjects    = length(var.github_oidc_subjects) > 0 ? var.github_oidc_subjects : ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"]
  tags_common = merge({ Project = var.cluster_name, Managed = "terraform" }, var.tags)
}

# -------------------------
# VPC (módulo oficial VPC)
# -------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags_common
}

# -------------------------
# EKS (módulo oficial EKS)
# -------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true
  enable_irsa                    = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Node group administrado (EC2)
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2_x86_64"
      instance_types = var.node_instance_types
      desired_size   = var.node_group_desired
      min_size       = 1
      max_size       = 4
    }
  }

  # Método moderno: Access entries (reemplaza aws-auth ConfigMap)
  access_entries = {
    # Access entry para tu usuario devops
    devops_user_admin = {
      principal_arn = "arn:aws:iam::${var.account_id}:user/devops-user"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    
    # Access entry para GitHub Actions (usando el rol de ECR)
    github_actions_deploy = {
      principal_arn = "arn:aws:iam::${var.account_id}:role/GitHubActions-ECRPush"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags_common
}

# -------------------------
# Datos del cluster (útil para kubectl)
# -------------------------
# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_name
# }