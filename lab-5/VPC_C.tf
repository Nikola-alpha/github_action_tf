variable "vpc_name_delta" {
  description = "The name of VPC."
}

variable "ec2_count_delta" {
  default = 2
}

module "vpc_delta" {
  source = "./modules/base-infra"
  cidr_block = "192.168.0.0/16"
  public_subnet_count = 2
  public_subnet_cidrs = ["192.168.0.0/24", "192.168.1.0/24"]
  vpc_name = var.vpc_name_delta
}
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc_delta.vpc_id
  cidr_block = "192.169.0.0/16"
}

# Create TLS keys
resource "tls_private_key" "ec2_delta_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "delta_key" {
  key_name   = "${var.vpc_name_delta}-public-key"
  public_key = tls_private_key.ec2_delta_key.public_key_openssh
  tags = {
    Name = "${var.vpc_name_delta}-public-key"
  }
}

resource "local_file" "delta_key" {
  content  = tls_private_key.ec2_delta_key.private_key_pem
  filename = "${path.module}/${var.vpc_name_delta}.pem"
}

resource "null_resource" "set_key_file_permissions_delta" {
  provisioner "local-exec" {
    command     = "chmod 400 ${local_file.delta_key.filename}"
    interpreter = ["sh", "-c"]
  }
    # Make sure this runs after the local file is created
  depends_on = [local_file.delta_key]
}

# Create Security groups
resource "aws_security_group" "delta_sg" {
  vpc_id = module.vpc_delta.vpc_id
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
    cidr_blocks = ["10.1.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2 with eip
resource "aws_instance" "delta" {
  count = var.ec2_count
  ami                         = "ami-025fe52e1f2dc5044"
  instance_type               = "t2.small"
  subnet_id                   = element(module.vpc_delta.public_subnet_ids, 0)
  key_name                    = aws_key_pair.delta_key.key_name
  vpc_security_group_ids      = [aws_security_group.delta_sg.id]
  associate_public_ip_address = false
  private_ip = "192.169.0.10"

  tags = {
    Name       = "${var.vpc_name_delta}-instance-${count.index}"
    Managed_by = local.Managed_by
  }
}
resource "aws_eip" "delta" {
  count = var.ec2_count
  domain = "vpc"
  instance = aws_instance.delta[count.index].id
  associate_with_private_ip = "192.169.0.10"
  tags = {
    Name       = "${var.vpc_name_delta}-eip"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_delta" {}