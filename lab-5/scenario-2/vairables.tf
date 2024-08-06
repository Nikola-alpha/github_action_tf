variable "region" {
  description = "The region of the AWS resources."
  type        = string
  default     = "us-east-1"
}
locals {
  Managed_by = "Terraform"
  Project    = "VPC-Peering"
}