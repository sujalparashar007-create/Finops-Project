variable "project_id" {
  description = "GCP project ID for the BigQuery views"
  type        = string
  default     = "my-project-id"
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "billing_export"
}

variable "billing_export_table_id" {
  description = "Fully qualified billing export table (project.dataset.table)"
  type        = string
  default     = "my-project.billing_export.gcp_billing_export_resource_v1_XXXXXX"
}

variable "budget_targets" {
  description = "Budget amount structs from finops-budgets module"
  type = list(object({
    month         = string
    project_id    = string
    currency      = string
    budget_amount = number
  }))
  default = [{
    month         = "2026-08"
    project_id    = "my-project"
    currency      = "USD"
    budget_amount = 1000
  }]
}
