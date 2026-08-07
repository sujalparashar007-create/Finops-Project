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

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]*(-[a-z]+[0-9]*)?$", var.region))
    error_message = "region must be a valid GCP region (e.g. us-east1, us-central1, europe-west1)."
  }
}

variable "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID to trigger the Cloud Function"
  type        = string

  validation {
    condition     = can(regex("^projects/[a-z][a-z0-9-]+/topics/.+$", var.pubsub_topic_id))
    error_message = "pubsub_topic_id must be a full Pub/Sub topic ID (projects/PROJECT/topics/NAME)."
  }
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
  default     = "finops-budget-alert-processor"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.function_name))
    error_message = "function_name must be a valid Cloud Function name (2-63 chars, lowercase letters, digits, hyphens)."
  }
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

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_.-]{1,221}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid GCS bucket name (3-222 chars, lowercase letters, digits, hyphens, underscores, dots)."
  }
}

variable "runtime" {
  description = "Cloud Function runtime"
  type        = string
  default     = "python311"

  validation {
    condition     = contains(["python310", "python311", "python312", "nodejs18", "nodejs20", "nodejs22"], var.runtime)
    error_message = "runtime must be a valid Cloud Functions runtime (e.g. python311, nodejs20)."
  }
}

variable "max_instance_count" {
  description = "Maximum number of Cloud Function instances"
  type        = number
  default     = 1

  validation {
    condition     = var.max_instance_count >= 1
    error_message = "max_instance_count must be at least 1."
  }
}

variable "available_memory" {
  description = "Memory allocated to the Cloud Function"
  type        = string
  default     = "256M"

  validation {
    condition     = can(regex("^[0-9]+(M|G|Gi|Mi)$", var.available_memory))
    error_message = "available_memory must be a valid memory spec (e.g. 256M, 1G, 512Mi)."
  }
}

variable "timeout_seconds" {
  description = "Cloud Function execution timeout in seconds"
  type        = number
  default     = 60

  validation {
    condition     = var.timeout_seconds > 0 && var.timeout_seconds <= 3600
    error_message = "timeout_seconds must be between 1 and 3600."
  }
}

variable "existing_service_account_email" {
  description = "Email of an existing service account to use as the Cloud Function runtime identity. When null (default), this module creates a dedicated runtime SA."
  type        = string
  default     = null

  validation {
    condition     = var.existing_service_account_email == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.iam\\.gserviceaccount\\.com$", var.existing_service_account_email))
    error_message = "existing_service_account_email must be a valid service account email when non-null."
  }
}

variable "runtime_sa_roles" {
  description = "Project-level IAM roles granted to the dedicated runtime SA when it is created by this module (i.e., when existing_service_account_email is null)."
  type        = list(string)
  default = [
    "roles/logging.logWriter",
  ]

  validation {
    condition     = alltrue([for r in var.runtime_sa_roles : can(regex("^roles/", r))])
    error_message = "Each runtime_sa_roles entry must start with 'roles/'."
  }
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
  description = "Additional members granted secretAccessor on specific secrets. Each entry specifies which secret key and which member."
  type = list(object({
    secret_key = string
    member     = string
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.secret_accessors :
      contains(keys(var.secret_environment), entry.secret_key) &&
      can(regex("^(user|group|serviceAccount|domain):.+", entry.member))
    ])
    error_message = "Each secret_accessors entry must reference a valid secret_key from secret_environment and have a member prefixed with user:, group:, serviceAccount:, or domain:."
  }
}

variable "enable_function" {
  description = "Set to false to skip Cloud Function creation (no budget alert processing)"
  type        = bool
  default     = true
}

