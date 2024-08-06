variable "vpc_name" {
  description = "The name of VPC."
}

variable "ec2_count" {
  default = 2
}

module "vpc_alpha" {
  source              = "../modules/base-infra"
  cidr_block          = "10.1.0.0/16"
  public_subnet_count = 2
  public_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
  vpc_name            = var.vpc_name
}

# Create TLS keys
resource "tls_private_key" "ec2_alpha_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "gen_key" {
  key_name   = "${var.vpc_name}-public-key"
  public_key = tls_private_key.ec2_alpha_key.public_key_openssh
  tags = {
    Name = "${var.vpc_name}-public-key"
  }
}

resource "local_file" "alpha_key" {
  content  = tls_private_key.ec2_alpha_key.private_key_pem
  filename = "${path.module}/${var.vpc_name}.pem"
}

resource "null_resource" "set_key_file_permissions" {
  provisioner "local-exec" {
    command     = "chmod 400 ${local_file.alpha_key.filename}"
    interpreter = ["sh", "-c"]
  }
  # Make sure this runs after the local file is created
  depends_on = [local_file.alpha_key]
}

# Create Security groups
resource "aws_security_group" "alpha_sg" {
  vpc_id = module.vpc_alpha.vpc_id
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
    cidr_blocks = ["192.168.0.0/16", "192.169.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2 with eip
resource "aws_instance" "alpha" {
  count                       = var.ec2_count
  ami                         = "ami-0ba9883b710b05ac6"
  instance_type               = "t3.micro"
  subnet_id                   = element(module.vpc_alpha.public_subnet_ids, 0)
  key_name                    = aws_key_pair.gen_key.key_name
  vpc_security_group_ids      = [aws_security_group.alpha_sg.id]
  associate_public_ip_address = false

  tags = {
    Name       = "${var.vpc_name}-instance-${count.index + 1}"
    Managed_by = local.Managed_by
  }
}
resource "aws_eip" "web" {
  count    = var.ec2_count
  domain   = "vpc"
  instance = aws_instance.alpha[count.index].id
  tags = {
    Name       = "${var.vpc_name}-eip-${count.index + 1}"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_alpha" {}


