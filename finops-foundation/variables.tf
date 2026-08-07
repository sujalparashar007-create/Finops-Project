# ==============================================================================
# MODULE: finops-foundation — variables
# ==============================================================================

# --- REQUIRED ---

variable "project_id" {
  description = "GCP project ID hosting the FinOps resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

# --- OPTIONAL ---

variable "activate_apis" {
  description = "List of GCP APIs to enable on the project (F13 — consolidated)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for api in var.activate_apis : can(regex("^[a-z][a-z0-9]*\\.googleapis\\.com$", api))])
    error_message = "Each activate_apis entry must be a valid GCP service name (e.g. pubsub.googleapis.com)."
  }
}

variable "iam" {
  description = "Project-level IAM bindings (F7 — additive). Key = IAM role, value = list of members"
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue(flatten([
      for role, members in var.iam : [
        for m in members : can(regex("^(user|group|serviceAccount|domain):.+", m))
      ]
    ]))
    error_message = "Each IAM member must be prefixed with user:, group:, serviceAccount:, or domain:."
  }
}
