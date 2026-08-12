# ==============================================================================
# MODULE: iam — variables
# ==============================================================================

variable "scope" {
  description = "Which resource type this binding set targets: organization, folder, or project."
  type        = string

  validation {
    condition     = contains(["organization", "folder", "project"], var.scope)
    error_message = "scope must be one of: organization, folder, project."
  }
}

variable "resource_id" {
  description = "The org ID, folder ID, or project ID this module grants IAM on, matching var.scope."
  type        = string
}

variable "iam_bindings_additive" {
  description = <<-EOT
    Additive IAM grants — one member + role per entry. This module is
    additive-only: it creates `google_*_iam_member` resources and never
    replaces a role's full membership, so it is safe to run alongside IAM
    changes made by other modules or teams. Each entry may carry an optional
    `condition` (rendered when `enable_conditional_bindings` is true).
  EOT
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, b in var.iam_bindings_additive :
      can(regex("^(group|serviceAccount|domain):", b.member)) &&
      (can(regex("^roles/", b.role)) || can(regex("^(projects|organizations|folders)/[^/]+/roles/", b.role)))
    ])
    error_message = "iam_bindings_additive members must be group:/serviceAccount:/domain: (never user:) and roles must be predefined (roles/...) or a custom role ID."
  }
}

variable "enable_conditional_bindings" {
  description = "Master switch for IAM Conditions support on iam_bindings_additive entries. Off by default — keeps the common unconditional case free of extra plan noise."
  type        = bool
  default     = false
}
