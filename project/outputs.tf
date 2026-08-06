# ==============================================================================
# MODULE: project — outputs
# ==============================================================================

output "project_id" {
  description = "GCP project ID — pass this to 6-finops as var.project_id"
  value       = google_project.project.project_id
}

output "project_number" {
  description = "Numeric project number — useful for billing export table references"
  value       = google_project.project.number
}

output "project_name" {
  description = "Display name of the GCP project"
  value       = google_project.project.name
}

output "terraform_sa_email" {
  description = "Full email of the tf-executor service account (e.g., tf-executor@PROJECT.iam.gserviceaccount.com)"
  value       = google_service_account.terraform.email
}

output "terraform_sa_name" {
  description = "Short account_id of the tf-executor service account"
  value       = google_service_account.terraform.account_id
}

output "terraform_sa_id" {
  description = "Full resource ID of the tf-executor service account (projects/PROJECT/serviceAccounts/EMAIL)"
  value       = google_service_account.terraform.name
}
