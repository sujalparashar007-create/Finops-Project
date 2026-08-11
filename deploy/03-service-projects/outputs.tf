# ==============================================================================
# STAGE 03: outputs (all keyed by host project ID)
# ==============================================================================

output "project_ids" {
  description = "Map of host project ID to its service project GCP ID"
  value       = module.service_projects.project_ids
}

output "project_names" {
  description = "Map of host project ID to its service project name"
  value       = module.service_projects.project_names
}

output "shared_vpc_attachment_ids" {
  description = "Map of host project ID to Shared VPC service project attachment ID"
  value       = module.service_projects.shared_vpc_attachment_ids
}

output "vm_ids" {
  description = "Map of host project ID to its service project VM self link"
  value       = module.service_projects.vm_ids
}

output "vm_names" {
  description = "Map of host project ID to its service project VM name"
  value       = module.service_projects.vm_names
}

output "vm_network_interfaces" {
  description = "Map of host project ID to its service project VM external IP (null when external_ip = false)"
  value       = module.service_projects.vm_network_interfaces
}
