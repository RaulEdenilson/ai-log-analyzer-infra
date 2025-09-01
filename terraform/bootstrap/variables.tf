variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "bucket_name" {
  type        = string
  default     = "raul-tfstate-dev" # cámbialo, debe ser único a nivel global en S3
}

variable "dynamodb_table" {
  type        = string
  default     = "tfstate-locks"
}

variable "env" {
  type        = string
  default     = "dev"
}

variable "owner" {
  type        = string
  default     = "Raul"
}
