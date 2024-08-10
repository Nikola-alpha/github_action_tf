# Transit Gateway
resource "aws_ec2_transit_gateway" "egress_tgw" {
  description = "Transit Gateway for Centralized Egress."
  tags = {
    Name = "Egress_TGW"
  }
}

# Transit Gateway Attachment for VPC Alpha
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_alpha" {
  transit_gateway_id                              = aws_ec2_transit_gateway.egress_tgw.id
  vpc_id                                          = module.vpc_alpha.vpc_id
  subnet_ids                                      = module.vpc_alpha.private_subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "Alpha_Att"
  }
}

# Transit Gateway Attachment for VPC Beta
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_beta" {
  transit_gateway_id                              = aws_ec2_transit_gateway.egress_tgw.id
  vpc_id                                          = module.vpc_beta.vpc_id
  subnet_ids                                      = module.vpc_beta.private_subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "Beta_Att"
  }
}

# Transit Gateway Attachment for VPC Delta
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_delta" {
  transit_gateway_id                              = aws_ec2_transit_gateway.egress_tgw.id
  vpc_id                                          = module.vpc_delta.vpc_id
  subnet_ids                                      = module.vpc_delta.private_subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "Delta_Att"
  }
}

# Transit Gateway Route Table for VPC Alpha
resource "aws_ec2_transit_gateway_route_table" "alpha_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.egress_tgw.id
  tags = {
    Name = "Alpha_tgw_rtb"
  }
}

# Transit Gateway Route Table for VPC Beta & Delta
resource "aws_ec2_transit_gateway_route_table" "egress_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.egress_tgw.id
  tags = {
    Name = "Egress_tgw_rtb"
  }
}

# Associate TGW Route Table with the Attachment_Alpha
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc_alpha" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.alpha_rtb.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_alpha.id
}

# Associate TGW Route Table with the Attachment_Beta
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc_beta" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rtb.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_beta.id
}

# Associate TGW Route Table with the Attachment_Delta
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc_delta" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rtb.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_delta.id
}

# Add Routes for the Transit Gateway
resource "aws_ec2_transit_gateway_route" "route_beta-delta_to_alpha" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rtb.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_alpha.id
}

# resource "aws_ec2_transit_gateway_route" "route_delta_to_alpha" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rtb.id
#   destination_cidr_block         = module.vpc_alpha.vpc_cidr_block
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_alpha.id
# }

resource "aws_ec2_transit_gateway_route" "route_alpha_to_beta" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.alpha_rtb.id
  destination_cidr_block         = module.vpc_beta.vpc_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_beta.id
}

resource "aws_ec2_transit_gateway_route" "route_alpha_to_delta" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.alpha_rtb.id
  destination_cidr_block         = module.vpc_delta.vpc_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_delta.id
}