# ==============================================================================
# MODULE: finops-dataset - variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID where the BigQuery dataset will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "dataset_id" {
  description = "BigQuery dataset ID (must be unique within the project)"
  type        = string
  default     = "billing_export"
}

variable "location" {
  description = "BigQuery dataset location (regional or multi-regional)"
  type        = string
  default     = "EU"

  validation {
    condition     = can(regex("^[a-zA-Z]+(-[a-zA-Z]+[0-9]*)*$", var.location))
    error_message = "location must be a valid GCP region or multi-region (e.g. EU, us-central1)."
  }
}

variable "labels" {
  description = "Labels to apply to the BigQuery dataset"
  type        = map(string)
  default     = {}
}

variable "iam" {
  description = "Dataset-level IAM bindings. Key = IAM role, value = list of members"
  type        = map(list(string))
  default     = {}

  # Example:
  # {
  #   "roles/bigquery.dataViewer" = ["group:finops-team@example.com"]
  #   "roles/bigquery.dataEditor" = ["serviceAccount:etl-sa@..."]
  # }
}
