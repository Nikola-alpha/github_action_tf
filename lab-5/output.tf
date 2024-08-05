output "vpc_id" {
  value = module.vpc_alpha.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc_alpha.public_subnet_ids
}

output "vpc_beta_id" {
  value = module.vpc_beta.vpc_id
}

output "public_subnet_ids_beta" {
  value = module.vpc_beta.public_subnet_ids
}

output "vpc_delta_id" {
  value = module.vpc_beta.vpc_id
}

output "public_subnet_ids_delta" {
  value = module.vpc_beta.public_subnet_ids
}

# output "name" {
#   value = module.vpc_delta.public_rtb_id
# }

# output "vpc_cidr_block" {
#   value = module.vpc_delta.vpc_cidr_block
# }

