variable "vpc_name" {
  description = "The name of the VPC"
  type = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 1
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
}
