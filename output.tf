output "network_name" {
  value       = module.vpc-module.network_name
  description = "The name of the VPC being created"
}

output "subnet_names" {
  value = module.vpc-module.subnets_names
}