variable "region" {
  description = "The region of the AWS resources."
  type = string
  default = "ap-south-1"
}
locals {
  Managed_by = "Terraform"
  Project   = "VPC-Peering"
}