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
  description = "BigQuery dataset ID (must be unique within the project). Ignored when existing_dataset_id is set."
  type        = string
  default     = "billing_export"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.dataset_id))
    error_message = "dataset_id must be a valid BigQuery dataset ID (letters, digits, underscores)."
  }
}

variable "existing_dataset_id" {
  description = "ID of an existing BigQuery dataset to use instead of creating one. When null (default), this module creates a new dataset."
  type        = string
  default     = null

  validation {
    condition     = var.existing_dataset_id == null || can(regex("^[a-zA-Z0-9_]+$", var.existing_dataset_id))
    error_message = "existing_dataset_id must be a valid BigQuery dataset ID when non-null."
  }
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
  description = "List of role/member grants. Each entry is one role assigned to one member."
  type = list(object({
    role   = string
    member = string
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.iam :
      can(regex("^roles/", entry.role)) &&
      can(regex("^(user|group|serviceAccount|domain):.+", entry.member))
    ])
    error_message = "Each iam entry must have role starting with 'roles/' and member prefixed with user:, group:, serviceAccount:, or domain:."
  }

  # Example:
  # [
  #   { role = "roles/bigquery.dataViewer", member = "group:finops-team@example.com" },
  #   { role = "roles/bigquery.dataEditor", member = "serviceAccount:etl-sa@..." },
  # ]
}

variable "enable_views" {
  description = "If true, create the BigQuery views supplied in var.views. If false, var.views is ignored and no views are created."
  type        = bool
  default     = true
}

variable "views" {
  description = "Map of BigQuery view definitions to create when enable_views = true. Key = view/table_id, value = { friendly_name, query }."
  type = map(object({
    friendly_name = string
    query         = string
  }))
  default = {}
}
