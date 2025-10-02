region        = "us-east-1"
cluster_name  = "ai-logs-eks"
account_id    = "625512666928"  # Your AWS account ID

github_org    = "RaulEdenilson"     # Your GitHub organization
github_repo   = "ai-log-analyzer-infra"      # Your repository name

# Optional: Define specific branches/workflows allowed
# github_oidc_subjects = [
#   "repo:RaulEdenilson/ai-log-analyzer-infra:ref:refs/heads/main",
#   "repo:RaulEdenilson/ai-log-analyzer-infra:ref:refs/heads/dev"
# ]

node_group_desired  = 2
node_instance_types = ["t3.medium"]

tags = {
  Environment = "development"
  Owner       = "Raul"
  Project     = "ai-logs"
}