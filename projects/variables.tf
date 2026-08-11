# ==============================================================================
# MODULE: projects — variables
# ==============================================================================

variable "billing_account_id" {
  description = "GCP billing account ID to link all created projects to."
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "projects" {
  description = <<-EOT
    Flat map of projects to create: key = project_id, value = its config.
    Mandatory labels: team, environment, cost_center, app, owner, location.
  EOT
  type = map(object({
    folder_id     = string
    activate_apis = optional(list(string), [])
    labels = object({
      team        = string
      environment = string
      cost_center = string
      app         = string
      owner       = string
      location    = string
    })
  }))

  validation {
    condition = alltrue([
      for pid, p in var.projects :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", pid))
    ])
    error_message = "Every project_id key must be a valid GCP project ID (6-30 chars, lowercase, digits, hyphens)."
  }
}
