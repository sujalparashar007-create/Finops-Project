# ==============================================================================
# MODULE: service-projects - outputs
# ==============================================================================
# All outputs are keyed by host project ID.

output "project_ids" {
  description = "Map of host project ID to its service project GCP ID"
  value       = { for k, v in module.projects : k => v.project_id }
}

output "project_names" {
  description = "Map of host project ID to its service project name"
  value       = { for k, v in module.projects : k => v.project_name }
}

output "terraform_sa_emails" {
  description = "Map of host project ID to its service project tf-executor SA email"
  value       = { for k, v in module.projects : k => v.terraform_sa_email }
}

output "shared_vpc_attachment_ids" {
  description = "Map of host project ID to Shared VPC service project attachment ID"
  value       = { for k, v in google_compute_shared_vpc_service_project.service : k => v.id }
}

output "vm_ids" {
  description = "Map of host project ID to its service project VM self link"
  value       = { for k, v in google_compute_instance.vm : k => v.self_link }
}

output "vm_names" {
  description = "Map of host project ID to its service project VM name"
  value       = { for k, v in google_compute_instance.vm : k => v.name }
}

output "vm_network_interfaces" {
  description = "Map of host project ID to its service project VM external IP (null when external_ip = false)"
  value       = { for k, v in google_compute_instance.vm : k => (length(v.network_interface[*].access_config[*].nat_ip) > 0 ? v.network_interface[0].access_config[0].nat_ip : null) }
}
