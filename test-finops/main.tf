# ==============================================================================
# MODULE 5: Integration & Validation - FinOps Root Configuration
# ==============================================================================
# Orchestrates all FinOps modules (0-4), deploys them together, creates the
# final monthly_kpi_summary view that joins daily_cost with finops_budgets,
# and exposes outputs for Dashboard 1 / Looker Studio consumption.
#
# Validation: after terraform apply, query the KPI view to confirm end-to-end
# data flow - billing export -> SQL views -> budgets -> monthly KPI summary.
#
# NOTE: Before first apply, manually grant the Terraform SA billing.admin on
# the billing account via GCP Console:
#   Billing -> Account Management -> [billing_account_id] -> Permissions
#   Add: tf-executor@[project_id].iam.gserviceaccount.com
#   Role: Billing Account Administrator
#
# Set enable_alert_function to false in .tfvars to stop email & Teams alerts.
# ==============================================================================

# ------------------------------------------------------------------------------
# LOCALS: load budget configuration from YAML + define foundation IAM/APIs
# ------------------------------------------------------------------------------
locals {
  budget_config = yamldecode(file(var.budgets_yaml_path))

  apis = [
    "billingbudgets.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

# ==============================================================================
# STEP 1: Foundation — APIs (F13) + Project-level IAM (F7)
#         Delegated to the finops-foundation module so that API enablement and
#         project-IAM are never scattered or duplicated across resources.
# ==============================================================================

module "finops_foundation" {
  source = "../finops-foundation"

  project_id    = var.project_id
  activate_apis = local.apis
  iam           = {}
}
# ==============================================================================
# STEP 3: Module 0 - BigQuery Dataset (depends on BigQuery IAM)
# ==============================================================================

module "finops_dataset" {
  source = "../finops-dataset"

  project_id   = var.project_id
  dataset_id   = var.dataset_id
  location     = var.dataset_location
  enable_views = true
  views        = local.finops_view_definitions

  labels = var.labels

  iam = var.dataset_iam

  depends_on = [
    module.finops_foundation,
    module.finops_budgets
  ]
}

# ==============================================================================
# STEP 5: Module 3 - Pub/Sub + Email Alert Channels (depends on APIs + IAM)
# ==============================================================================

module "finops_alerts" {
  source = "../finops-alerts"

  project_id   = var.project_id
  topic_name   = var.topic_name
  alert_emails = var.alert_emails

  depends_on = [
    module.finops_foundation
  ]
}

# ==============================================================================
# STEP 6: Module 2 - Billing Budgets (depends on alerts + billingbudgets API)
# ==============================================================================

module "finops_budgets" {
  source = "../finops-budgets"

  billing_account          = var.billing_account_id
  pubsub_topic_id          = module.finops_alerts.pubsub_topic_id
  notification_channel_ids = module.finops_alerts.notification_channel_ids

  budgets = merge(
    local.budget_config.budgets,
    local.budget_config.budget_control_scopes,
  )

  iam_viewers = var.iam_viewers

  depends_on = [
    module.finops_foundation,
    module.finops_alerts
  ]
}

# ==============================================================================
# STEP 7: Cloud Function — Budget Alert Processor
# ==============================================================================
# Deployed via the dedicated finops-function module.

module "finops_function" {
  source = "../finops-function"

  project_id          = var.project_id
  region              = var.region
  pubsub_topic_id     = module.finops_alerts.pubsub_topic_id
  function_name       = "finops-budget-alert-processor"
  function_source_dir = "${path.module}/function-source"
  bucket_name         = var.function_bucket_name
  runtime             = var.function_runtime
  enable_function     = var.enable_alert_function

  environment_variables = {}

  secret_environment = {
    TEAMS_WEBHOOK_URL = var.teams_webhook_url
  }

  depends_on = [
    module.finops_foundation,
    module.finops_alerts,
  ]
}
