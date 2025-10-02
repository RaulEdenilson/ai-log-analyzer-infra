terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE" # o "IMMUTABLE" si no quieres sobrescribir tags
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256" # o KMS si quieres una CMK
  }

  tags = var.tags
}

# Política de ciclo de vida: conserva últimas N imágenes por tag, limpia viejas
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = file("${path.module}/lifecycle.json")
}

# 2) (Opcional pero recomendado) OIDC + Role para GitHub Actions
# Proveedor OIDC de GitHub (crea si no existe ya en tu cuenta; si ya existe, puedes importarlo)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

# Role asumido por GitHub Actions (restringido a tu repo/branch)
data "aws_iam_policy_document" "gha_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Ajusta owner/repo y rama
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "gha_ecr_push" {
  name               = "GitHubActions-ECRPush"
  assume_role_policy = data.aws_iam_policy_document.gha_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability", "ecr:CompleteLayerUpload",
      "ecr:CreateRepository", "ecr:DescribeRepositories",
      "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart",
      "ecr:ListImages", "ecr:DescribeImages"
    ]
    resources = [aws_ecr_repository.this.arn]
  }

  # EKS permissions for deployment
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_push_inline" {
  name   = "ECRPushPolicy"
  role   = aws_iam_role.gha_ecr_push.id
  policy = data.aws_iam_policy_document.ecr_push.json
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "gha_role_arn" {
  value       = aws_iam_role.gha_ecr_push.arn
  description = "Pega este ARN en el workflow de GitHub (role-to-assume)"
}
