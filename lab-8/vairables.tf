variable "region" {
  description = "The region of the AWS resources."
  type        = string
  default     = "ap-northeast-1"
}

locals {
  Managed_by = "Terraform"
  Project    = "Route-53_endpoint"
}

variable "ec2-ami" {
  description = "The ami id of the ec2."
  type        = string
  default     = "ami-0091f05e4b8ee6709"
}