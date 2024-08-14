terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
  bucket         = "my-tf-state-bucket"
  key            = "tf-state"
  region         = var.region
  dynamodb_table = "tf_lock_table"
}
}



provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}