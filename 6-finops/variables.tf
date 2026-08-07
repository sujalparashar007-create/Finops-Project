# ==============================================================================
# MODULE 5: Integration & Validation -- variables
# ==============================================================================
# All hardcoded values extracted into typed variables so this root module can
# be reused across environments or customers. Sensitive values (passwords,
# webhook URLs) are marked sensitive and default to empty strings.
# ==============================================================================

# ------------------------------------------------------------------------------
# REQUIRED -- no safe default; must be provided per environment
# ------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID hosting all FinOps resources (BigQuery, Cloud Function, Pub/Sub, etc.)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "billing_account_id" {
  description = "GCP billing account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "org_id" {
  description = "GCP Organization ID (numeric) — required for hierarchical firewall policy"
  type        = string
}

variable "billing_export_table_id" {
  description = "Fully qualified BigQuery billing export table (project.dataset.table)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+\\.[a-zA-Z0-9_]+\\.[a-zA-Z0-9_]+$", var.billing_export_table_id))
    error_message = "billing_export_table_id must be in project.dataset.table format."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL -- have sensible defaults but can be overridden
# ------------------------------------------------------------------------------

variable "region" {
  description = "GCP region for regional resources (Cloud Function, GCS bucket, Pub/Sub trigger)"
  type        = string
  default     = "us-east1"
}

variable "dataset_location" {
  description = "BigQuery dataset location (regional or multi-regional, e.g. EU, us-central1)"
  type        = string
  default     = "EU"
}

variable "dataset_id" {
  description = "BigQuery dataset ID (must be unique within the project)"
  type        = string
  default     = "billing_export"
}

variable "topic_name" {
  description = "Pub/Sub topic name for budget alerts"
  type        = string
  default     = "finops-budget-alerts"
}

variable "enable_alert_function" {
  description = "Set to false to stop all email and Teams budget alert notifications"
  type        = bool
  default     = true
}

variable "function_bucket_name" {
  description = "GCS bucket name for storing Cloud Function source code"
  type        = string
  default     = "finops-function-source"
}

variable "function_runtime" {
  description = "Cloud Function runtime (Python version)"
  type        = string
  default     = "python311"
}

variable "labels" {
  description = "Labels applied to the BigQuery dataset"
  type        = map(string)
  default = {
    environment = "demo"
    managed_by  = "terraform"
  }
}

# ------------------------------------------------------------------------------
# IAM / ALERTING
# ------------------------------------------------------------------------------

variable "alert_emails" {
  description = "Email addresses that receive budget alert notifications"
  type        = list(string)
  default     = []
}

variable "iam_viewers" {
  description = "List of members (user:, group:, serviceAccount:) granted billing account viewer for scoped budget controls"
  type        = list(string)
  default     = []
}

variable "dataset_iam" {
  description = "List of role/member grants for the FinOps BigQuery dataset."
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}

# ------------------------------------------------------------------------------
# BUDGET CONFIGURATION -- loaded from YAML file
# ------------------------------------------------------------------------------

variable "budgets_yaml_path" {
  description = "Path to the YAML file containing budget definitions (budgets, budget_view_data, budget_control_scopes)"
  type        = string
  default     = "budgets.yaml"
}

# ------------------------------------------------------------------------------
# SENSITIVE -- credentials for the Cloud Function alert processor
# Set via terraform.tfvars (gitignored) or TF_VAR_ environment variables.
# ------------------------------------------------------------------------------

variable "gmail_user" {
  description = "Gmail address used to send budget alert emails from the Cloud Function"
  type        = string
  sensitive   = true
  default     = ""
}

variable "gmail_app_password" {
  description = "Gmail app password for SMTP authentication (NOT the account password)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "teams_webhook_url" {
  description = "Microsoft Teams / Power Automate webhook URL for budget alert notifications"
  type        = string
  sensitive   = true
  default     = ""
}
