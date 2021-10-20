output "network_name" {
  value       = google_compute_network.network.name
  description = "The name of the VPC being created"
}
output "subnets_names" {
  value = [for i in google_compute_subnetwork.subnetwork : i.name]
}


