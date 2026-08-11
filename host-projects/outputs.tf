# ==============================================================================
# MODULE: host-projects — outputs
# ==============================================================================

output "project_ids" {
  description = "Map of logical project name to GCP project ID"
  value       = { for k, v in module.projects : k => v.project_id }
}

output "project_names" {
  description = "Map of logical project name to GCP project name"
  value       = { for k, v in module.projects : k => v.project_name }
}

output "terraform_sa_emails" {
  description = "Map of logical project name to tf-executor SA email"
  value       = { for k, v in module.projects : k => v.terraform_sa_email }
}

output "folder_ids" {
  description = "Map of folder name to folder ID"
  value       = module.folders.folder_ids
}

output "folder_names" {
  description = "Map of folder name to full resource name"
  value       = module.folders.folder_names
}
