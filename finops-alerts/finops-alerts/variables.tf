# ==============================================================================
# MODULE: finops-alerts - variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID where Pub/Sub topic and notification channels are created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "topic_name" {
  description = "Pub/Sub topic name for budget alert events"
  type        = string
  default     = "finops-budget-alerts"
}

variable "alert_emails" {
  description = "List of email addresses to notify on budget threshold breaches"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels applied to the Pub/Sub topic"
  type        = map(string)
  default = {
    environment = "finops"
    managed_by  = "terraform"
  }
}
