output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_rtb_ids" {
  value = aws_route_table.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_rtb_ids" {
  value = aws_route_table.private.*.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "igw" {
  value = aws_internet_gateway.igw.*.id
}