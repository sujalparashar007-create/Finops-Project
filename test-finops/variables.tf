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

  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID (e.g. 123456789012)."
  }
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

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]*(-[a-z]+[0-9]*)?$", var.region))
    error_message = "region must be a valid GCP region (e.g. us-east1, us-central1, europe-west1)."
  }
}

variable "dataset_location" {
  description = "BigQuery dataset location (regional or multi-regional, e.g. EU, us-central1)"
  type        = string
  default     = "EU"

  validation {
    condition     = can(regex("^[a-zA-Z]+(-[a-zA-Z]+[0-9]*)*$", var.dataset_location))
    error_message = "dataset_location must be a valid GCP region or multi-region (e.g. EU, us-central1)."
  }
}

variable "dataset_id" {
  description = "BigQuery dataset ID (must be unique within the project)"
  type        = string
  default     = "billing_export"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.dataset_id))
    error_message = "dataset_id must be a valid BigQuery dataset ID (letters, digits, underscores)."
  }
}

variable "topic_name" {
  description = "Pub/Sub topic name for budget alerts"
  type        = string
  default     = "finops-budget-alerts"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_.~+%]{2,255}$", var.topic_name))
    error_message = "topic_name must be a valid Pub/Sub topic name (3-255 chars, letters, digits, hyphens, underscores, dots, tildes, percent, plus)."
  }
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

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_.-]{1,221}[a-z0-9]$", var.function_bucket_name))
    error_message = "function_bucket_name must be a valid GCS bucket name (3-222 chars, lowercase letters, digits, hyphens, underscores, dots)."
  }
}

variable "function_runtime" {
  description = "Cloud Function runtime (Python version)"
  type        = string
  default     = "python311"

  validation {
    condition     = contains(["python310", "python311", "python312", "nodejs18", "nodejs20", "nodejs22"], var.function_runtime)
    error_message = "function_runtime must be a valid Cloud Functions runtime (e.g. python311, nodejs20)."
  }
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

  validation {
    condition     = alltrue([for e in var.alert_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", e))])
    error_message = "Each alert_emails entry must be a valid email address (e.g. user@example.com)."
  }
}

variable "iam_viewers" {
  description = "List of members (user:, group:, serviceAccount:) granted billing account viewer for scoped budget controls"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for m in var.iam_viewers : can(regex("^(user|group|serviceAccount|domain):.+", m))])
    error_message = "Each iam_viewers member must be prefixed with user:, group:, serviceAccount:, or domain:."
  }
}

variable "dataset_iam" {
  description = "List of role/member grants for the FinOps BigQuery dataset."
  type = list(object({
    role   = string
    member = string
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.dataset_iam :
      can(regex("^roles/", entry.role)) &&
      can(regex("^(user|group|serviceAccount|domain):.+", entry.member))
    ])
    error_message = "Each dataset_iam entry must have role starting with 'roles/' and member prefixed with user:, group:, serviceAccount:, or domain:."
  }
}

# ------------------------------------------------------------------------------
# BUDGET CONFIGURATION -- loaded from YAML file
# ------------------------------------------------------------------------------

variable "budgets_yaml_path" {
  description = "Path to the YAML file containing budget definitions (budgets, budget_view_data, budget_control_scopes)"
  type        = string
  default     = "budgets.yaml"

  validation {
    condition     = can(regex("\\.ya?ml$", var.budgets_yaml_path))
    error_message = "budgets_yaml_path must point to a YAML file (.yaml or .yml)."
  }
}

# ------------------------------------------------------------------------------
# SENSITIVE -- credentials for the Cloud Function alert processor
# Set via terraform.tfvars (gitignored) or TF_VAR_ environment variables.
# ------------------------------------------------------------------------------

variable "teams_webhook_url" {
  description = "Microsoft Teams / Power Automate webhook URL for budget alert notifications"
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.teams_webhook_url == "" || can(regex("^https://", var.teams_webhook_url))
    error_message = "teams_webhook_url must start with https:// when non-empty."
  }
}
