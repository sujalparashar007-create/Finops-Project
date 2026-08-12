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
  description = "The org/folder/project ID the deny policy attaches to. For scope = folders/organizations this MUST be the numeric ID (e.g. \"123456789012\") — folders and orgs have no string alias the way a project has project_id. For scope = projects, the project_id string is correct."
  type        = string

  validation {
    condition     = var.scope == "projects" || can(regex("^[0-9]+$", var.target_id))
    error_message = "target_id must be numeric when scope is 'folders' or 'organizations' (use the folder/org number, not its display name)."
  }
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
  description = "Flat list of deny rules: denied permissions/roles for a set of principals, with optional exceptions and an optional CEL condition."
  type = list(object({
    denied_principals     = list(string)
    denied_permissions    = list(string)
    exception_principals  = optional(list(string), [])
    exception_permissions = optional(list(string), [])
    denial_condition = optional(object({
      title       = string
      expression  = string
      description = optional(string, "")
      location    = optional(string, "")
    }), null)
    reason = string
  }))

  validation {
    condition = alltrue([
      for r in var.deny_rules : length(r.reason) > 0
    ])
    error_message = "Each deny rule must document a 'reason'."
  }
}
