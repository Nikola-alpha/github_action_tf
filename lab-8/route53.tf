resource "aws_route53_zone" "private-cloud-aws" {
  name = "mingalabar.cloud"

  vpc {
    vpc_id = module.vpc_beta.vpc_id
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private-cloud-aws.id
  name    = "app.mingalabar.cloud"
  type    = "A"
  ttl     = 300
  records = [aws_instance.beta.private_ip]
}

# Create a security group for the Route 53 Resolver outbound endpoint
resource "aws_security_group" "resolver_sg" {
  name        = "resolver_sg"
  description = "Security group for Route 53 Resolver outbound endpoint"
  vpc_id      = module.vpc_beta.vpc_id

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Route 53 Resolver outbound endpoint
resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  direction = "OUTBOUND"
  security_group_ids = [
    aws_security_group.resolver_sg.id,
  ]

  ip_address {
    subnet_id = module.vpc_beta.public_subnet_ids[0]
  }
  ip_address {
    subnet_id = module.vpc_beta.public_subnet_ids[1]  # Subnet for the outbound endpoint
  }

  tags = {
    Name = "cloud_to_onprem_endpoint"
  }
}

# Create a forwarding rule for DNS queries
resource "aws_route53_resolver_rule" "forwarding_rule" {
  domain_name          = "app.mingalabar.cloud"  # Replace with the domain you want to forward
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.id

  target_ip {
    ip   = aws_instance.bastion_host.private_ip  # Replace with the target DNS resolver IP address
    port = 53
  }

  tags = {
    Name = "cloud_to_onprem_rule"
  }
}

# Create the Route 53 Resolver inbound endpoint
resource "aws_route53_resolver_endpoint" "inbound_endpoint" {
  name      = "onprem_to_cloud"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.resolver_sg.id
  ]

  ip_address {
    subnet_id = module.vpc_beta.public_subnet_ids[0]
  }

  ip_address {
    subnet_id = module.vpc_beta.public_subnet_ids[1]
  }

  protocols = ["Do53"]

  tags = {
    Name = "onprem_to_cloud"
  }
}
