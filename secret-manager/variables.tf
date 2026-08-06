# ==============================================================================
# MODULE: secret-manager — variables
# ==============================================================================

# --- REQUIRED ---

variable "project_id" {
  description = "GCP project ID where Secret Manager secrets will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

# --- OPTIONAL ---

variable "secrets" {
  description = "Map of secret IDs to their payload values. Key = Secret Manager secret_id, value = secret data."
  type        = map(string)
  default     = {}

  # NOTE: sensitive = true is omitted intentionally. Terraform does not allow
  # sensitive maps in for_each. The secret values are stored in Secret Manager
  # at rest; the caller's variables (gmail_app_password, etc.) remain sensitive.
}

variable "accessors" {
  description = "List of members (user:, group:, serviceAccount:) granted roles/secretmanager.secretAccessor on every secret"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.accessors) == 0 || alltrue([
      for m in var.accessors : can(regex("^(user|group|serviceAccount|domain):.+", m))
    ])
    error_message = "Each accessor member must be prefixed with user:, group:, serviceAccount:, or domain:."
  }
}
