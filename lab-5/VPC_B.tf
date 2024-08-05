variable "vpc_name_beta" {
  description = "The name of VPC."
}

variable "ec2_count_beta" {
  default = 2
}

module "vpc_beta" {
  source = "./modules/base-infra"
  cidr_block = "192.168.0.0/16"
  public_subnet_count = 2
  public_subnet_cidrs = ["192.168.0.0/24", "192.168.1.0/24"]
  vpc_name = var.vpc_name_beta
}

# Create TLS keys
resource "tls_private_key" "ec2_beta_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "beta_key" {
  key_name   = "${var.vpc_name_beta}-public-key"
  public_key = tls_private_key.ec2_beta_key.public_key_openssh
  tags = {
    Name = "${var.vpc_name_beta}-public-key"
  }
}

resource "local_file" "beta_key" {
  content  = tls_private_key.ec2_beta_key.private_key_pem
  filename = "${path.module}/${var.vpc_name_beta}.pem"
}

resource "null_resource" "set_key_file_permissions_beta" {
  provisioner "local-exec" {
    command     = "chmod 400 ${local_file.beta_key.filename}"
    interpreter = ["sh", "-c"]
  }
    # Make sure this runs after the local file is created
  depends_on = [local_file.beta_key]
}

# Create Security groups
resource "aws_security_group" "beta_sg" {
  vpc_id = module.vpc_beta.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2 with eip
resource "aws_instance" "beta" {
  count = var.ec2_count
  ami                         = "ami-025fe52e1f2dc5044"
  instance_type               = "t2.small"
  subnet_id                   = element(module.vpc_beta.public_subnet_ids, 0)
  key_name                    = aws_key_pair.beta_key.key_name
  vpc_security_group_ids      = [aws_security_group.beta_sg.id]
  associate_public_ip_address = false

  tags = {
    Name       = "${var.vpc_name_beta}-instance-${count.index}"
    Managed_by = local.Managed_by
  }
}
resource "aws_eip" "beta" {
  count = var.ec2_count
  domain = "vpc"
  instance = aws_instance.beta[count.index].id
  tags = {
    Name       = "${var.vpc_name_beta}-eip"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_beta" {}