# ==============================================================================
# EXAMPLE: project module — basic usage
# ==============================================================================
# Standalone root module that creates a FinOps-ready GCP project.
# Run:  cd examples/basic && terraform init && terraform apply
#
# IMPORTANT:
#   - Apply with your OWN credentials (gcloud auth application-default login).
#   - Do NOT set impersonate_service_account — the SA doesn't exist yet.
#   - After apply, enable billing export to BigQuery manually.
# ==============================================================================

module "project" {
  source = "../../"

  project_id         = var.project_id
  project_name       = var.project_name
  billing_account_id = var.billing_account_id
  org_id             = var.org_id
  folder_id          = var.folder_id
  terraform_user     = var.terraform_user

  # terraform_sa_name         = "tf-executor"     # default
  # terraform_sa_display_name = "Terraform Executor SA"
  # terraform_sa_roles        = default 7 roles
  # activate_apis             = []
}
