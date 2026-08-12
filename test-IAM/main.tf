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

# ------------------------------------------------------------------------------
# 6. FACTORY (consolidated) — YAML-driven FinOps resources
#    Previously three separate factory modules (project-factory,
#    identities-factory, hierarchical-iam-factory). Their functionality now
#    lives here and is read directly from top-level YAML files in this module,
#    created as part of the bootstrap deployment:
#      projects.yaml          -> FinOps projects + project-level IAM
#      identities.yaml        -> FinOps service accounts + roles
#      hierarchical-iam.yaml  -> FinOps folders + folder-level IAM
# ------------------------------------------------------------------------------
locals {
  factory_projects   = try(yamldecode(file("${path.module}/projects.yaml")).projects, {})
  factory_identities = try(yamldecode(file("${path.module}/identities.yaml")).service_accounts, {})
  factory_hier_iam   = try(yamldecode(file("${path.module}/hierarchical-iam.yaml")), {})
}

# --- 6a. YAML-driven FinOps projects (was project-factory) --------------------
module "factory_projects" {
  source = "../projects"

  billing_account_id = var.billing_account_id

  projects = {
    for pid, p in local.factory_projects : pid => {
      folder_id     = p.folder_id
      activate_apis = try(p.activate_apis, [])
      labels        = p.labels
    }
  }
}

module "factory_project_iam" {
  source   = "../iam"
  for_each = local.factory_projects

  scope                 = "project"
  resource_id           = module.factory_projects.project_ids[each.key]
  iam_bindings_additive = try(each.value.iam_bindings_additive, {})

  depends_on = [module.factory_projects]
}

# --- 6b. YAML-driven FinOps service accounts (was identities-factory) ---------
module "factory_identities" {
  source           = "../identities"
  service_accounts = local.factory_identities
}

# --- 6c. YAML-driven FinOps folders + folder IAM (was hierarchical-iam-factory)
module "factory_folders" {
  source  = "../folder"
  folders = try(local.factory_hier_iam.folders, {})
}

module "factory_folder_iam" {
  source   = "../iam"
  for_each = { for k, v in local.factory_hier_iam.hierarchical_iam : k => v.bindings }

  scope                 = "folder"
  resource_id           = module.factory_folders.folder_ids[each.key]
  iam_bindings_additive = each.value

  depends_on = [module.factory_folders]
}