# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {}

# Transit Gateway Attachment for VPC A
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_a" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc_alpha.vpc_id
  subnet_ids         = [module.vpc_alpha.private_subnet_ids[0]]
}