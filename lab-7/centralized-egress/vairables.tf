variable "region" {
  description = "The region of the AWS resources."
  type        = string
  default     = "ap-southeast-1"
}

locals {
  Managed_by = "Terraform"
  Project    = "VPC-Peering"
}

variable "ec2-ami" {
  description = "The ami id of the ec2."
  type = string
  default = "ami-0a6b545f62129c495"
}