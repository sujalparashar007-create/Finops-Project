# ==============================================================================
# ROOT MODULE: bootstrap — Stage 0 GCP Project + tf-executor Bootstrap
# ==============================================================================
# Creates a fresh GCP project with billing, provisions the tf-executor service
# account, grants the project-level roles it needs, and wires up impersonation.
# Run this FIRST, before any other FinOps Terraform configuration.
#
# IMPORTANT: Apply this with your OWN user credentials (not impersonating
# tf-executor — it doesn't exist yet). The provider must NOT set
# impersonate_service_account.
#
# This replaces the legacy standalone project/ bootstrap module. Project
# creation lives in ../projects, SA creation lives in ../identities, and the
# bootstrap-specific grants (billing account admin + user token creator) are
# declared here directly because they have no home in the general modules.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. GCP PROJECT — via the landing-zone projects module
# ------------------------------------------------------------------------------
module "projects" {
  source = "../projects"

  billing_account_id = var.billing_account_id

  projects = {
    (var.project_id) = {
      folder_id     = var.folder_id
      activate_apis = var.activate_apis
      labels = {
        team        = var.project_label_team
        environment = var.project_label_environment
        cost_center = var.project_label_cost_center
        app         = var.project_label_app
        owner       = var.project_label_owner
        location    = var.project_label_location
      }
    }
  }
}

# ------------------------------------------------------------------------------
# 2. TF-EXECUTOR SERVICE ACCOUNT + its project-level roles — via identities
# ------------------------------------------------------------------------------
module "identities" {
  source = "../identities"

  service_accounts = {
    (var.terraform_sa_name) = {
      project_id   = var.project_id
      display_name = var.terraform_sa_display_name
      roles        = var.terraform_sa_roles
    }
  }

  depends_on = [module.projects]
}

# ------------------------------------------------------------------------------
# 3. BILLING ACCOUNT IAM — grant tf-executor billing.admin on the billing account
#    (required for budget creation). Bootstrap-specific, so declared here.
# ------------------------------------------------------------------------------
resource "google_billing_account_iam_member" "terraform_sa_billing_admin" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.admin"
  member             = "serviceAccount:${module.identities.emails[var.terraform_sa_name]}"
}

# ------------------------------------------------------------------------------
# 4. SERVICE ACCOUNT IAM — allow the human user to impersonate tf-executor
#    Bootstrap-specific, so declared here.
# ------------------------------------------------------------------------------
resource "google_service_account_iam_member" "user_token_creator" {
  service_account_id = module.identities.names[var.terraform_sa_name]
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.terraform_user
}

# ------------------------------------------------------------------------------
# 5. ACT-AS SELF — allow tf-executor to act as itself (Cloud Function identity)
#    Bootstrap-specific, so declared here.
# ------------------------------------------------------------------------------
resource "google_service_account_iam_member" "tf_executor_act_as_self" {
  service_account_id = module.identities.names[var.terraform_sa_name]
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.identities.emails[var.terraform_sa_name]}"
}