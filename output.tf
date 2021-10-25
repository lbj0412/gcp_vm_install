output "VPC_name" {
  value       = module.vpc-module.network_name
  description = "The name of the VPC being created"
}

output "Subnet_names" {
  value = module.vpc-module.subnets_names
}

output "Instance_name_ip_address" {
  value = [for i in module.compute_instance.instances_details : join("/", [i.name], [i.network_interface[0].access_config[0].nat_ip])]
}

# output "self_link" {
#   description = "Self-link of instance template"
#   value       = [for i in module.instance_template : i.self_link]
# }

# output "template_name" {
#   description = "Self-link of instance template"
#   value       = [for i in module.instance_template : i.template_name]
# }