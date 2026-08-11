# ==============================================================================
# MODULE: finops-policy — variables
# ==============================================================================

# --- REQUIRED ---

variable "scope" {
  description = "Where the policy is applied: organization or folder"
  type        = string

  validation {
    condition     = contains(["organization", "folder", "project"], var.scope)
    error_message = "scope must be 'organization', 'folder', or 'project'."
  }
}

# --- CONDITIONAL (required based on scope) ---

variable "org_id" {
  description = "GCP Organization ID (required when scope = organization)"
  type        = string
  default     = ""

  validation {
    condition     = var.org_id == "" || var.scope != "organization" || can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID when scope is 'organization' (e.g. 123456789012)."
  }
}

variable "folder_id" {
  description = "GCP Folder ID (required when scope = folder)"
  type        = string
  default     = ""

  validation {
    condition     = var.folder_id == "" || var.scope != "folder" || can(regex("^[0-9]{5,25}$", var.folder_id))
    error_message = "folder_id must be a numeric GCP Folder ID when scope is 'folder' (e.g. 123456789)."
  }
}

variable "project_id" {
  description = "GCP Project ID (required when scope = project)"
  type        = string
  default     = ""

  validation {
    condition     = var.project_id == "" || var.scope != "project" || can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID when scope is 'project' (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "network" {
  description = "VPC network name (required when scope = project)"
  type        = string
  default     = ""

  validation {
    condition     = var.network == "" || var.scope != "project" || can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.network))
    error_message = "network must be a valid VPC network name when scope is 'project' (lowercase letters, digits, hyphens)."
  }
}

# --- OPTIONAL ---

variable "policy_suffix" {
  description = "Suffix for policy short name (keep under ~10 chars)"
  type        = string
  default     = "foundation"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,9}$", var.policy_suffix))
    error_message = "policy_suffix must be 1-10 lowercase alphanumeric/dash chars."
  }
}

variable "rules" {
  description = "Map of firewall rules. Add/remove entries to change policy."
  type = map(object({
    priority       = number
    action         = string
    direction      = optional(string, "INGRESS")
    src_ranges     = list(string)
    ports          = list(string)
    description    = string
    enable_logging = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for key, rule in var.rules :
      contains(["allow", "deny"], rule.action) &&
      contains(["INGRESS", "EGRESS"], rule.direction) &&
      rule.priority > 0
    ])
    error_message = "Each rule must have action = 'allow' or 'deny', direction = 'INGRESS' or 'EGRESS', and priority > 0."
  }
}

variable "org_iam_bindings" {
  description = "Map of org-level IAM bindings (role → member). Only applies when scope = organization."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}
