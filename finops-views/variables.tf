# ==============================================================================
# MODULE: finops-views - variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID where the BigQuery views will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "dataset_id" {
  description = "BigQuery dataset ID (from Module 0 output)"
  type        = string
}

variable "billing_export_table_id" {
  description = "Fully qualified billing export table ID (project.dataset.gcp_billing_export_resource_v1_XXXXXX). Leave empty if billing export is not yet configured - no views will be created."
  type        = string
  default     = ""

  validation {
    condition     = var.billing_export_table_id == "" || can(regex("^[a-z][a-z0-9-]+\\.[a-zA-Z0-9_]+\\.[a-zA-Z0-9_]+$", var.billing_export_table_id))
    error_message = "billing_export_table_id must be in project.dataset.table format, or empty string."
  }
}

variable "budget_targets" {
  description = "List of budget amount structs from finops-budgets module (month, project_id, currency, budget_amount) used to build the finops_budgets view"
  type = list(object({
    month         = string
    project_id    = string
    currency      = string
    budget_amount = number
  }))
  default = []
}
