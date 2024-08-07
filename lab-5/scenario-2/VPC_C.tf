variable "vpc_name_delta" {
  description = "The name of VPC."
}

variable "ec2_count_delta" {
  default = 1
}

module "vpc_delta" {
  source              = "../modules/base-infra"
  cidr_block          = "192.168.0.0/16"
  public_subnet_count = 1
  public_subnet_cidrs = ["192.168.0.0/24"]
  vpc_name            = var.vpc_name_delta
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc_delta.vpc_id
  cidr_block = "192.169.0.0/16"
}

resource "aws_subnet" "secondary_public" {
  vpc_id                  = module.vpc_delta.vpc_id
  cidr_block              = "192.169.0.0/24"
  map_public_ip_on_launch = true
  depends_on = [ aws_vpc_ipv4_cidr_block_association.secondary_cidr ]

  tags = {
    Name = "${var.vpc_name_delta}-secondary-public-subnet"
  }
}
resource "aws_route_table" "secondary_public_rtb" {
  vpc_id = module.vpc_delta.vpc_id
  tags = {
    Name = "${var.vpc_name_delta}-secondary-public-rtb"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.secondary_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_delta.igw
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.secondary_public.id
  route_table_id = aws_route_table.secondary_public_rtb.id
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
  count                       = var.ec2_count_delta
  ami                         = "ami-0ba9883b710b05ac6"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.secondary_public.id
  key_name                    = aws_key_pair.delta_key.key_name
  vpc_security_group_ids      = [aws_security_group.delta_sg.id]
  # associate_public_ip_address = false
  private_ip                  = "192.169.0.10"

  tags = {
    Name       = "${var.vpc_name_delta}-instance-${count.index + 1}"
    Managed_by = local.Managed_by
  }
}
resource "aws_eip" "delta" {
  count                     = var.ec2_count_delta
  domain                    = "vpc"
  instance                  = aws_instance.delta[count.index].id
  associate_with_private_ip = "192.169.0.10"
  tags = {
    Name       = "${var.vpc_name_delta}-eip"
    Managed_by = local.Managed_by
  }
}

# Data source to get the current AWS region
data "aws_region" "vpc_delta" {}