output "region" { value = var.region }
output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "cluster_arn" { value = module.eks.cluster_arn }
output "gha_role_arn" { value = aws_iam_role.github_actions_deploy.arn }
output "node_role_arn" { value = module.eks.eks_managed_node_groups["default"].iam_role_arn }
