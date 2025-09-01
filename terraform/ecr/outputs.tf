output "repository_name" { value = aws_ecr_repository.this.name }
output "repository_url"  { value = aws_ecr_repository.this.repository_url }
output "role_arn"        { value = aws_iam_role.gha_ecr_push.arn }
