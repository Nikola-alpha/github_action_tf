output "vpc_alpha_id" {
  value       = module.vpc_alpha.vpc_id
  description = "The Name of On-prem VPC"
}

output "public_subnet_ids" {
  value = module.vpc_alpha.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc_alpha.private_subnet_ids
}

output "vpc_beta_id" {
  value       = module.vpc_beta.vpc_id
  description = "The Name of Cloud VPC"
}

output "public_subnet_ids_beta" {
  value = module.vpc_beta.public_subnet_ids
}

output "bastion_ssh_command" {
  value       = "ssh -i ${local_file.alpha_key.filename} ec2-user@${aws_eip.bastion_eip.public_ip}"
  description = "Command to SSH into the bastion host"
}

output "onprem-app-ip" {
  value       = aws_instance.app_svr.private_ip
  description = "The Private IP of onprem-app server"
}

output "cloud-app-ip" {
  value       = aws_instance.beta.private_ip
  description = "The Private IP of cloud-app server"
}