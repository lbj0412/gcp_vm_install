output "VPC_name" {
  value       = module.vpc-module.network_name
  description = "The name of the VPC being created"
}

output "Subnet_names" {
  value = module.vpc-module.subnets_names
}

output "Instance_name_ip_address" {
  sensitive = false
  value     = [for i in keys(local.vm_instance) : zipmap(module.compute_instance[i].instances_name,flatten(module.compute_instance[i].instances_ip))]
}

# output "self_link" {
#   description = "Self-link of instance template"
#   value       = [for i in module.instance_template : i.self_link]
# }

# output "template_name" {
#   description = "Self-link of instance template"
#   value       = [for i in module.instance_template : i.template_name]
# }