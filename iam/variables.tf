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
    Additive IAM grants — one member + role per entry, safe alongside bindings
    made elsewhere. This is the default choice; use `iam` or `iam_bindings` only
    when this module call should fully own a role's membership.
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

variable "iam" {
  description = "Authoritative role -> members map. Only set a role here if this module call should fully own that role's membership (removes anything not listed)."
  type        = map(list(string))
  default     = {}
}

variable "iam_bindings" {
  description = "Authoritative, condition-aware bindings. Rare — prefer iam_bindings_additive unless a time-boxed authoritative grant is genuinely required."
  type = map(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

variable "enable_conditional_bindings" {
  description = "Master switch for IAM Conditions support on iam_bindings_additive/iam_bindings entries. Off by default — keeps the common unconditional case free of extra plan noise."
  type    = bool
  default = false
}
