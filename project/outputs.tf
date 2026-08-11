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

output "org_iam_binding_ids" {
  description = "Map of org IAM role to resource ID (null when org_id is not set or no org_iam_roles provided)"
  value       = var.org_id != "" && length(var.org_iam_roles) > 0 ? { for k, v in google_organization_iam_member.terraform_sa_org_roles : k => v.id } : null
}

output "billing_user_granted" {
  description = "True if roles/billing.user was granted to tf-executor on the billing account"
  value       = var.billing_user
}

output "operator_impersonation_granted_to" {
  description = "List of operators granted tokenCreator on tf-executor"
  value       = var.terraform_operators
}
