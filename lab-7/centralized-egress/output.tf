output "vpc_id" {
  value = module.vpc_alpha.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc_alpha.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc_alpha.private_subnet_ids
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
output "bastion_ssh_command" {
  value       = "ssh -i ${local_file.alpha_key.filename} ec2-user@${aws_eip.bastion_eip[0].public_ip}"
  description = "Command to SSH into the bastion host"
}

output "beta_svr_ip" {
  value = aws_instance.beta[0].private_ip
  description = "Private ip of the Beta "
}
output "delta_svr_ip" {
  value = aws_instance.delta[0].private_ip
  description = "Private ip of the Beta instance"
}


# output "bastion_ssh_command_for_serverAC" {
#   value       = "ssh -i ${local_file.alpha_key.filename} ec2-user@${aws_eip.web[1].public_ip}"
#   description = "Command to SSH into the bastion host"
# }
