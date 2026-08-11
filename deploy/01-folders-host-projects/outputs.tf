# ==============================================================================
# STAGE 01: outputs — consumed by 02-hub-spoke and 03-service-projects
# ==============================================================================

output "project_ids" {
  description = "Map of logical project name to GCP project ID (e.g. network -> foundation-network)"
  value       = module.host_projects.project_ids
}

output "project_names" {
  description = "Map of logical project name to GCP project display name"
  value       = module.host_projects.project_names
}

output "terraform_sa_emails" {
  description = "Map of logical project name to its tf-executor SA email"
  value       = module.host_projects.terraform_sa_emails
}

output "folder_ids" {
  description = "Map of folder name to folder ID"
  value       = module.host_projects.folder_ids
}

output "folder_names" {
  description = "Map of folder name to full resource name (folders/NNN)"
  value       = module.host_projects.folder_names
}
