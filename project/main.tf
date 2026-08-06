# ==============================================================================
# MODULE: project — GCP Project Bootstrap (Stage 0)
# ==============================================================================
# Creates a GCP project with billing, the tf-executor service account, and all
# IAM grants required by the 6-finops root module. Use this as the very first
# module before running any other FinOps Terraform configuration.
#
# IMPORTANT: Apply this module with your OWN user credentials (not impersonating
# tf-executor — it doesn't exist yet). The provider must NOT set
# impersonate_service_account.
#
# After this module is applied:
#   1. Enable billing export to BigQuery on the billing account (manual step).
#   2. Run the 6-finops root module with impersonation enabled.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. GCP PROJECT
# ------------------------------------------------------------------------------
resource "google_project" "project" {
  project_id      = var.project_id
  name            = var.project_name
  org_id          = var.org_id != "" ? var.org_id : null
  folder_id       = var.folder_id != "" ? var.folder_id : null
  billing_account = var.billing_account_id
}

# ------------------------------------------------------------------------------
# 2. TERRAFORM SERVICE ACCOUNT — tf-executor (impersonated by 6-finops)
# ------------------------------------------------------------------------------
resource "google_service_account" "terraform" {
  account_id   = var.terraform_sa_name
  display_name = var.terraform_sa_display_name
  project      = google_project.project.project_id
}

# ------------------------------------------------------------------------------
# 3. PROJECT-LEVEL IAM — grant tf-executor every role it needs
# ------------------------------------------------------------------------------
resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset(var.terraform_sa_roles)

  project = google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# ------------------------------------------------------------------------------
# 4. SERVICE ACCOUNT IAM — allow the human user to impersonate tf-executor
# ------------------------------------------------------------------------------
resource "google_service_account_iam_member" "user_token_creator" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.terraform_user
}

# ------------------------------------------------------------------------------
# 5. BILLING ACCOUNT IAM — grant tf-executor billing.admin (required for budget creation)
# ------------------------------------------------------------------------------
resource "google_billing_account_iam_member" "terraform_sa_billing_admin" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.terraform.email}"
}

# ------------------------------------------------------------------------------
# 6. ACT-AS PERMISSIONS — allow tf-executor to deploy Cloud Functions
#    Cloud Functions require the deploying SA to act as the App Engine and
#    Compute Engine default service accounts at deploy time.
# ------------------------------------------------------------------------------

# Allow tf-executor to act as itself (needed for Cloud Function identity)
resource "google_service_account_iam_member" "tf_executor_act_as_self" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.terraform.email}"
}

# ------------------------------------------------------------------------------
# 7. OPTIONAL — enable APIs early (FinOps-specific APIs are handled by finops-foundation)
# ------------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = toset(var.activate_apis)

  project            = google_project.project.project_id
  service            = each.key
  disable_on_destroy = false
}
