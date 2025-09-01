variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "ecr_name" {
  type        = string
  default     = "ai-log-analyzer"
}

variable "github_owner" { type = string } # RaulEdenilson
variable "github_repo"  { type = string } # ai-log-analyzer
variable "github_branch" {
  type    = string
  default = "main"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "ai-log-analyzer"
    Owner   = "Raul"
    Env     = "dev"
  }
}
