terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
  bucket         = "tf-sys-bucket"
  key            = "tf-state"
  region         = "ap-southeast-1"
  dynamodb_table = "tf_lock_table"
}
}



provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}