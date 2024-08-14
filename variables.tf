variable "region" {
  description = "AWS Region for the resources."
  type        = string
  default = "ap-southeast-1"
}
variable "AWS_ACCESS_KEY_ID" {
  description = "Access Key ID for AWS."
  type = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  description = "Secret Access Key ID for AWS."
  type = string
}

locals {
  Managed_by   = "Terraform"
  Project_Name = "Module_lab"
}
# variable "env" {
#   description = "The environment name (uat, staging, prod)."
#   type        = string
# }

