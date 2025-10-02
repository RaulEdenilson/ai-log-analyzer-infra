region        = "us-east-1"
cluster_name  = "ai-logs-eks"
account_id    = "YOUR_AWS_ACCOUNT_ID"  # Replace with your actual AWS account ID

github_org    = "YOUR_GITHUB_ORG"     # Replace with your GitHub organization
github_repo   = "YOUR_REPO_NAME"      # Replace with your repository name

# Optional: Define specific branches/workflows allowed
# github_oidc_subjects = [
#   "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:ref:refs/heads/main",
#   "repo:YOUR_GITHUB_ORG/YOUR_REPO_NAME:ref:refs/heads/dev"
# ]

node_group_desired  = 2
node_instance_types = ["t3.medium"]

tags = {
  Environment = "development"
  Owner       = "your-name"
  Project     = "ai-logs"
}