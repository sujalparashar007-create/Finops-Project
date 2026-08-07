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

variable "existing_service_account_email" {
  description = "Email of an existing service account to use as the Cloud Function runtime identity. When null (default), this module creates a dedicated runtime SA."
  type        = string
  default     = null
}

variable "runtime_sa_roles" {
  description = "Project-level IAM roles granted to the dedicated runtime SA when it is created by this module (i.e., when existing_service_account_email is null)."
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

variable "existing_secret_ids" {
  description = "Map of secret key → existing Secret Manager secret ID. Keys present here skip secret creation; the caller must already own the secret."
  type        = map(string)
  default     = {}
}

variable "secret_accessors" {
  description = "Additional members (besides the runtime SA) granted secretAccessor on this function's secrets."
  type        = list(string)
  default     = []
}

variable "enable_function" {
  description = "Set to false to skip Cloud Function creation (no budget alert processing)"
  type        = bool
  default     = true
}

