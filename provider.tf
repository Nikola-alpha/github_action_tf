terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.62.0"
    }
  }
  backend "s3" {
    bucket         = "tf-sys-bucket"
    key            = "tf-state-github"
    region         = "ap-southeast-1"
    dynamodb_table = "tf_lock_table"
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  default_tags {
    tags = {
      Managed_by = "Terraform"
      Environment = "pipeline"
    }
    
  }
}