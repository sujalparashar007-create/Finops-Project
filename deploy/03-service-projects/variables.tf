# ==============================================================================
# STAGE 03: variables
# ==============================================================================

variable "org_id" {
  description = "GCP Organization ID (numeric)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID (e.g. 123456789012)."
  }
}

variable "billing_account_id" {
  description = "GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "terraform_user" {
  description = "Human user granted roles/iam.serviceAccountTokenCreator on each tf-executor SA. Must be prefixed with user:."
  type        = string

  validation {
    condition     = can(regex("^user:", var.terraform_user))
    error_message = "terraform_user must be prefixed with 'user:' (e.g., user:john@example.com)."
  }
}

variable "region" {
  description = "Default GCP region for the service project VMs"
  type        = string
}

variable "hub_project_key" {
  description = "Logical key (from stage 01 projects) of the host project whose tf-executor SA runs this stage"
  type        = string
  default     = "network"
}

variable "hosts" {
  description = "Map of service project definitions. Key = logical name. Value = { host_project_key, service_project_id, service_project_name, subnet_source, vm }. subnet_source = 'hub' for the hub subnet, or a spoke logical name from stage 02 for a spoke subnet."
  type = map(object({
    host_project_key     = string
    service_project_id   = string
    service_project_name = string
    subnet_source        = string
    vm = object({
      name         = string
      machine_type = string
      zone         = string
      boot_image   = optional(string, "debian-cloud/debian-12")
      tags         = optional(list(string), [])
      metadata     = optional(map(string), {})
      external_ip  = optional(bool, true)
    })
  }))
}
