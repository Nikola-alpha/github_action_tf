resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  count  = var.public_subnet_count
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-public-rtb-${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
    count  = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-private-rtb-${count.index + 1}"
  }
}

resource "aws_route" "internet_access" {
    count                  = var.public_subnet_count
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.create_igw ? aws_internet_gateway.igw[0].id : null
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "public_subnet" {
  count          = var.public_subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private_subnet" {
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}