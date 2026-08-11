# ==============================================================================
# MODULE: folder — variables
# ==============================================================================

variable "folders" {
  description = "Flat map of folders to create: key = folder display name, value = its config."
  type = map(object({
    parent = string # "organizations/<org_id>" or "folders/<parent_folder_id>"
    tags   = optional(map(string), {}) # Resource Manager Tags — folders have no `labels` field
  }))
}
