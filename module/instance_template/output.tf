output "instance_template" {
  value = google_compute_instance_template.tpl
}
output "self_link" {
  description = "Self-link of instance template"
  value       = google_compute_instance_template.tpl.self_link
}

output "template_name" {
  value = google_compute_instance_template.tpl.name_prefix
}