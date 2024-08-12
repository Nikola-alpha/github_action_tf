variable "vpc_name_beta" {
  description = "The name of VPC."
}

# variable "ec2_count_beta" {
#   default = 1
# }

module "vpc_beta" {
  source               = "../vpc-modules/base-infra"
  cidr_block           = "172.32.0.0/16"
  public_subnet_count  = 2
  public_subnet_cidrs  = ["172.32.0.0/24", "172.32.1.0/24"]
  vpc_name             = var.vpc_name_beta
  private_subnet_count = 0
  private_subnet_cidrs = ["172.32.2.0/24"]
}

# Create Security groups
resource "aws_security_group" "beta_sg" {
  vpc_id = module.vpc_beta.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name_beta}-sg"
  }
}

# Create ec2 with eip
resource "aws_instance" "beta" {
  # count                       = var.ec2_count_beta
  ami                         = var.ec2-ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_beta.public_subnet_ids, 0)
  key_name                    = aws_key_pair.gen_key.key_name
  vpc_security_group_ids      = [aws_security_group.beta_sg.id]
  associate_public_ip_address = false

  tags = {
    Name       = "${var.vpc_name_beta}-App"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_beta" {}