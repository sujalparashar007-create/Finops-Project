# ==============================================================================
# MODULE: folder — GCP Folder Factory
# ==============================================================================
# Creates one or more folders under a given parent (organization or folder)
# with optional folder-level IAM bindings.
#
# Usage example:
#   module "environment_folders" {
#     source = "../folder"
#
#     parent     = "organizations/123456789"
#     names      = ["network", "development"]
#     folder_iam = {
#       dev_creator = {
#         folder_key = "development"
#         role       = "roles/resourcemanager.projectCreator"
#         member     = "group:dev-team@example.com"
#       }
#     }
#   }
# ==============================================================================

variable "parent" {
  description = "Parent organization or folder (e.g., 'organizations/123456789' or 'folders/987654321')"
  type        = string

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "parent must be in format 'organizations/NNN' or 'folders/NNN'."
  }
}

variable "names" {
  description = "List of folder display names to create"
  type        = list(string)
  default     = ["folder-network", "folder-development"]
}

variable "folder_iam_bindings" {
  description = "Map of folder-level IAM bindings. Key = binding id, value = { folder_key, role, member }"
  type = map(object({
    folder_key = string
    role       = string
    member     = string
  }))
  default = {}
}