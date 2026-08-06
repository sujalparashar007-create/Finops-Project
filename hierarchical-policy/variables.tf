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
}

variable "folder_id" {
  description = "GCP Folder ID (required when scope = folder)"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "GCP Project ID (required when scope = project)"
  type        = string
  default     = ""
}

variable "network" {
  description = "VPC network name (required when scope = project)"
  type        = string
  default     = ""
}

# --- OPTIONAL ---

variable "policy_suffix" {
  description = "Suffix for policy short name (keep under ~10 chars)"
  type        = string
  default     = "foundation"
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
}
