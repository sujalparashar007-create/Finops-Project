# ==============================================================================
# STAGE 01: variables
# ==============================================================================

variable "org_id" {
  description = "GCP Organization ID (numeric)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID (e.g. 123456789012)."
  }
}

variable "billing_account_id" {
  description = "GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "terraform_user" {
  description = "Human user granted roles/iam.serviceAccountTokenCreator on each tf-executor SA. Must be prefixed with user:."
  type        = string

  validation {
    condition     = can(regex("^user:", var.terraform_user))
    error_message = "terraform_user must be prefixed with 'user:' (e.g., user:john@example.com)."
  }
}

variable "projects" {
  description = "Map of host projects to create. Key = logical name (used as the state lookup key downstream), value = { project_id, project_name, folder_name }."
  type = map(object({
    project_id   = string
    project_name = string
    folder_name  = string
  }))
}
