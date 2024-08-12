variable "vpc_name" {
  description = "The name of VPC."
}

variable "ec2_count" {
  default = 1
}

module "vpc_alpha" {
  source              = "../vpc-modules/base-infra"
  cidr_block          = "10.1.0.0/16"
  public_subnet_count = 2
  public_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
  vpc_name            = var.vpc_name
  private_subnet_count = 0
  private_subnet_cidrs = ["10.1.2.0/24"]
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
    cidr_blocks = ["192.168.0.0/16", "10.1.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2 with eip
resource "aws_instance" "bastion_host" {
  count                       = var.ec2_count
  ami                         = var.ec2-ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_alpha.public_subnet_ids, 0)
  key_name                    = aws_key_pair.gen_key.key_name
  vpc_security_group_ids      = [aws_security_group.alpha_sg.id]
  associate_public_ip_address = false

  tags = {
    Name       = "${var.vpc_name}-instance-${count.index + 1}"
    Managed_by = local.Managed_by
  }
}
resource "aws_eip" "bastion_eip" {
  count    = var.ec2_count
  domain   = "vpc"
  instance = aws_instance.bastion_host[count.index].id
  tags = {
    Name       = "${var.vpc_name}-eip-${count.index + 1}"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_alpha" {}

# Configure bastion SSH
resource "null_resource" "configure_ssh" {
  depends_on = [aws_instance.bastion_host, aws_eip.bastion_eip]

  provisioner "file" {
    source      = local_file.alpha_key.filename
    destination = "/home/ec2-user/.ssh/bastion_key.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.ec2_alpha_key.private_key_pem
      host        = aws_eip.bastion_eip[0].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/bastion_key.pem",
      "echo '${tls_private_key.ec2_alpha_key.public_key_openssh}' >> /home/ec2-user/.ssh/authorized_keys"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.ec2_alpha_key.private_key_pem
      host        = aws_eip.bastion_eip[0].public_ip
    }
  }
}
