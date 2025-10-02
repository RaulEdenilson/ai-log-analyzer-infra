terraform {
  backend "s3" {
    bucket         = "raul-tfstate-dev"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}
