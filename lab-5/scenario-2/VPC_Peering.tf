resource "aws_vpc_peering_connection" "Alpha_to_Beta" {
  peer_vpc_id = module.vpc_beta.vpc_id
  vpc_id      = module.vpc_alpha.vpc_id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "Alpha-to-Beta"
  }
}

resource "aws_route" "route_Alpha_to_Beta" {
  route_table_id            = module.vpc_alpha.public_rtb_ids[0]
  destination_cidr_block    = module.vpc_beta.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.Alpha_to_Beta.id
}

resource "aws_route" "route_Beta_to_Alpha" {
  route_table_id            = module.vpc_beta.public_rtb_ids[0]
  destination_cidr_block    = module.vpc_alpha.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.Alpha_to_Beta.id
}

resource "aws_vpc_peering_connection" "Alpha_to_Delta" {
  peer_vpc_id = module.vpc_delta.vpc_id
  vpc_id      = module.vpc_alpha.vpc_id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "Alpha-to-Delta"
  }
}

resource "aws_route" "route_Alpha_to_Delta" {
  route_table_id            = module.vpc_alpha.public_rtb_ids[1]
  destination_cidr_block    = aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.Alpha_to_Delta.id
}

resource "aws_route" "route_Delta_to_Alpha" {
  route_table_id            = aws_route_table.secondary_public_rtb.id
  destination_cidr_block    = module.vpc_alpha.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.Alpha_to_Delta.id
}