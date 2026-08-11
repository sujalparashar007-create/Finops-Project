# ==============================================================================
# MODULE: iam-deny-policy — variables
# ==============================================================================

variable "scope" {
  description = "Where the deny policy attaches: organizations, folders, or projects"
  type        = string

  validation {
    condition     = contains(["organizations", "folders", "projects"], var.scope)
    error_message = "scope must be 'organizations', 'folders', or 'projects'."
  }
}

variable "target_id" {
  description = "The org/folder/project ID the deny policy attaches to"
  type        = string
}

variable "policy_name" {
  description = <<-EOT
    Unique name for this deny policy resource, scoped to (scope, target_id).
    REQUIRED to be unique per team/purpose — google_iam_deny_policy is
    authoritative for its own (parent, name) pair, so two different teams
    calling this module against the SAME target_id must use DIFFERENT
    policy_name values (e.g. "networking-guardrails",
    "external-access-guardrails") or they will silently overwrite each
    other's rules.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,61}$", var.policy_name))
    error_message = "policy_name must be lowercase alphanumeric/dash, 3-62 chars."
  }
}

variable "deny_rules" {
  description = "Flat list of deny rules: denied permissions/roles for a set of principals, with optional exceptions."
  type = list(object({
    denied_principals  = list(string)
    denied_permissions = list(string)
    exception_principals = optional(list(string), [])
    reason             = string
  }))

  validation {
    condition = alltrue([
      for r in var.deny_rules : length(r.reason) > 0
    ])
    error_message = "Each deny rule must document a 'reason'."
  }
}
