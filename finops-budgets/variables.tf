# ==============================================================================
# MODULE: finops-budgets - variables
# ==============================================================================

variable "billing_account" {
  description = "GCP billing account ID"
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account))
    error_message = "billing_account must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID from Module 3"
  type        = string
  default     = ""
}

variable "notification_channel_ids" {
  description = "Map of email → notification channel ID from Module 3 (finops-alerts output)"
  type        = map(string)
  default     = {}
}

variable "budgets" {
  description = "Map of budget definitions (includes scoping fields for per-project/folder budgets and budget-target metadata for the finops-views module)"
  type = map(object({
    display_name  = string
    currency_code = optional(string, "USD")
    units         = string
    threshold_rules = list(object({
      threshold_percent = number
      spend_basis       = optional(string, "CURRENT_SPEND")
    }))
    monitoring_notification_channels = optional(list(string), [])
    disable_default_iam_recipients   = optional(bool, false)
    enable_project_level_recipients  = optional(bool, true)
    credit_types_treatment           = optional(string, "INCLUDE_ALL_CREDITS")
    filter_projects                  = optional(list(string))
    calendar_period                  = optional(string, "MONTH")
    budget_month                     = optional(string)
    budget_project                   = optional(string)
  }))
  default = {}
}

variable "iam_viewers" {
  description = "List of members to grant billing viewer (can see budgets)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for m in var.iam_viewers : can(regex("^(user|group|serviceAccount|domain):.+", m))])
    error_message = "Each iam_viewers member must be prefixed with user:, group:, serviceAccount:, or domain:."
  }
}
