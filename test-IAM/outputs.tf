# ==============================================================================
# ROOT MODULE: bootstrap — outputs
# ==============================================================================

output "project_id" {
  description = "GCP project ID — pass this to test-finops as var.project_id"
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

# --- Factory outputs (consolidated from the former factory modules) ---

output "factory_project_ids" {
  description = "Map of FinOps factory project key -> created GCP project ID"
  value       = module.factory_projects.project_ids
}

output "factory_project_numbers" {
  description = "Map of FinOps factory project key -> numeric project number"
  value       = module.factory_projects.project_numbers
}

output "factory_iam_scopes" {
  description = "Map of FinOps factory project key -> IAM module scope/resource_id"
  value = {
    for pid in keys(module.factory_projects.project_ids) : pid => {
      scope       = "project"
      resource_id = module.factory_projects.project_ids[pid]
    }
  }
}

output "factory_sa_emails" {
  description = "Map of FinOps factory SA account_id -> SA email"
  value       = module.factory_identities.emails
}

output "factory_sa_names" {
  description = "Map of FinOps factory SA account_id -> SA fully-qualified resource name"
  value       = module.factory_identities.names
}

output "factory_folder_ids" {
  description = "Map of FinOps factory folder display name -> folder ID"
  value       = module.factory_folders.folder_ids
}

output "factory_folder_names" {
  description = "Map of FinOps factory folder display name -> folder resource name"
  value       = module.factory_folders.folder_names
}