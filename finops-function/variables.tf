# ==============================================================================
# MODULE: finops-function - variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID for the Cloud Function and GCS bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "region" {
  description = "GCP region for the Cloud Function and GCS bucket"
  type        = string
  default     = "us-east1"
}

variable "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID to trigger the Cloud Function"
  type        = string
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
  default     = "finops-budget-alert-processor"
}

variable "function_source_dir" {
  description = "Path to the directory containing the Cloud Function source code (main.py, requirements.txt)"
  type        = string
  default     = "function-source"
}

variable "bucket_name" {
  description = "Name of the GCS bucket for storing Cloud Function source code"
  type        = string
  default     = "finops-function-source"
}

variable "runtime" {
  description = "Cloud Function runtime"
  type        = string
  default     = "python311"
}

variable "max_instance_count" {
  description = "Maximum number of Cloud Function instances"
  type        = number
  default     = 1
}

variable "available_memory" {
  description = "Memory allocated to the Cloud Function"
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "Cloud Function execution timeout in seconds"
  type        = number
  default     = 60
}

variable "service_account_email" {
  description = "Service account email for the Cloud Function runtime identity. Required when create_service_account = false."
  type        = string
  default     = ""
}

variable "create_service_account" {
  description = "If true, this module creates a dedicated runtime service account instead of requiring one via service_account_email (CFF pattern)."
  type        = bool
  default     = true
}

variable "runtime_sa_roles" {
  description = "Project-level IAM roles granted to the dedicated runtime SA when create_service_account = true"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
  ]
}

variable "environment_variables" {
  description = "Environment variables passed to the Cloud Function runtime"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "secret_environment" {
  description = "Secrets stored in Secret Manager and exposed to the Cloud Function runtime (e.g. passwords, webhook URLs). Key = env var name exposed to function, value = secret payload."
  type        = map(string)
  default     = {}
}

variable "enable_function" {
  description = "Set to false to skip Cloud Function creation (no budget alert processing)"
  type        = bool
  default     = true
}
