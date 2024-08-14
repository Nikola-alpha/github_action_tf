variable "AWS_REGION" {
  description = "The region of the AWS resources."
  type        = string
  default     = "ap-southeast-1"
}
locals {
  Managed_by = "Terraform"
  Project    = "VPC-Peering"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}