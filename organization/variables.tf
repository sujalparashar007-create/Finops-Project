# ==============================================================================
# MODULE: organization — variables
# ==============================================================================

variable "org_id" {
  description = "GCP Organization ID (numeric)."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID."
  }
}

variable "tags" {
  description = <<-EOT
    Org-level metadata via Resource Manager Tags. NOT `labels`. GCP does not
    support a `labels` field on `google_organization` the way it does on
    `google_project`; Tags are the equivalent mechanism here. Flat map:
    key = tag key short name (e.g. "business-unit"), value = tag value short
    name (e.g. "businesssvc"). Tag keys/values must already exist (created
    once, referenced everywhere) — this module only binds them.
  EOT
  type    = map(string)
  default = {}
}
