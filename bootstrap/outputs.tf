# ==============================================================================
# ROOT MODULE: bootstrap — outputs
# ==============================================================================

output "project_id" {
  description = "GCP project ID — pass this to 6-finops as var.project_id"
  value       = var.project_id
}

output "project_number" {
  description = "Numeric project number — useful for billing export table references"
  value       = module.projects.project_numbers[var.project_id]
}

output "terraform_sa_email" {
  description = "Full email of the tf-executor service account"
  value       = module.identities.emails[var.terraform_sa_name]
}

output "terraform_sa_name" {
  description = "Short account_id of the tf-executor service account"
  value       = var.terraform_sa_name
}

output "terraform_sa_id" {
  description = "Full resource ID of the tf-executor service account"
  value       = module.identities.names[var.terraform_sa_name]
}