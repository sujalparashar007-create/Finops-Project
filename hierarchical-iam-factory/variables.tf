# ==============================================================================
# MODULE: hierarchical-iam-factory — variables
# ==============================================================================

variable "folders" {
  description = "Flat map of folders to create: key = folder display name, value = its config. Passed through to the `folder` module."
  type = map(object({
    parent = string
    tags   = optional(map(string), {})
  }))
}