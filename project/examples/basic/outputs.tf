# ==============================================================================
# EXAMPLE: project module — outputs
# ==============================================================================

output "project_id" {
  description = "GCP project ID — pass to 6-finops as var.project_id"
  value       = module.project.project_id
}

output "project_number" {
  description = "Numeric project number"
  value       = module.project.project_number
}

output "project_name" {
  description = "Display name"
  value       = module.project.project_name
}

output "terraform_sa_email" {
  description = "SA email for 6-finops provider impersonation"
  value       = module.project.terraform_sa_email
}
