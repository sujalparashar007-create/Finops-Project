# ==============================================================================
# MODULE: project-factory — variables
# ==============================================================================

variable "billing_account_id" {
  description = "GCP billing account ID to link all created projects to."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}
