output "project_ids" {
  description = "Map of host project ID to its service project GCP ID"
  value       = module.service_projects.project_ids
}

output "vm_names" {
  description = "Map of host project ID to its service project VM name"
  value       = module.service_projects.vm_names
}

output "vm_network_interfaces" {
  description = "Map of host project ID to its service project VM external IP"
  value       = module.service_projects.vm_network_interfaces
}

output "shared_vpc_attachment_ids" {
  description = "Map of host project ID to Shared VPC attachment ID"
  value       = module.service_projects.shared_vpc_attachment_ids
}
