# ==============================================================================
# MODULE: custom-iam-roles — variables
# ==============================================================================

variable "scope" {
  description = "Where the custom role is defined: organization or project"
  type        = string

  validation {
    condition     = contains(["organization", "project"], var.scope)
    error_message = "scope must be 'organization' or 'project' (custom roles cannot be defined at folder scope)."
  }
}

variable "org_id" {
  description = "GCP Organization ID (required when scope = organization)"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "GCP Project ID (required when scope = project)"
  type        = string
  default     = ""
}

variable "custom_roles" {
  description = "Flat list of custom role definitions. Only add an entry after confirming no predefined role fits — document why in `reason`."
  type = list(object({
    role_id     = string
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
    reason      = string
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.custom_roles :
      length(r.permissions) > 0 && length(r.reason) > 0
    ])
    error_message = "Each custom role must list at least one permission and a non-empty 'reason'."
  }
}
