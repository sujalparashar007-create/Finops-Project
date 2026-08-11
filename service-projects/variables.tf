# ==============================================================================
# MODULE: service-projects - variables
# ==============================================================================
# Creates one service project per host project.
#
# Usage example:
#   module "service_projects" {
#     source = "../service-projects"
#
#     org_id             = "563019909339"
#     billing_account_id = "01A325-032DBC-FAB4E4"
#     terraform_user     = "user:sujalparashar007@gmail.com"
#
#     hosts = {
#       foundation-network = {
#         service_project_id   = "svc-network"
#         service_project_name = "Network Service Project"
#         vm = {
#           name                 = "net-vm"
#           machine_type         = "e2-small"
#           zone                 = "us-central1-a"
#           subnetwork_self_link = "projects/foundation-network/regions/us-central1/subnetworks/sb-hub"
#         }
#       }
#       foundation-development = {
#         service_project_id   = "svc-development"
#         service_project_name = "Development Service Project"
#         vm = {
#           name                 = "dev-vm"
#           machine_type         = "e2-medium"
#           zone                 = "us-central1-b"
#           subnetwork_self_link = "projects/foundation-development/regions/us-central1/subnetworks/sb-spoke"
#         }
#       }
#     }
#   }
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
  description = "Human user granted roles/iam.serviceAccountTokenCreator on the tf-executor SA so they can impersonate it. Must be prefixed with 'user:'."
  type        = string

  validation {
    condition     = can(regex("^user:", var.terraform_user))
    error_message = "terraform_user must be prefixed with 'user:' (e.g., 'user:john@example.com')."
  }
}

variable "hosts" {
  description = "Map of host project ID -> service project definition. One service project (with a VM) is created per host. Value = { service_project_id, service_project_name, vm }."
  type = map(object({
    service_project_id   = string
    service_project_name = string
    vm = object({
      name                 = string
      machine_type         = string
      zone                 = string
      subnetwork_self_link = string
      boot_image           = optional(string, "debian-cloud/debian-12")
      tags                 = optional(list(string), [])
      metadata             = optional(map(string), {})
      external_ip          = optional(bool, true)
    })
  }))
}

variable "service_project_sa_roles" {
  description = "List of IAM roles granted to the tf-executor SA in each service project"
  type        = list(string)
  default = [
    "roles/compute.instanceAdmin",
    "roles/compute.networkUser",
    "roles/compute.securityAdmin",
    "roles/storage.objectAdmin",
    "roles/logging.logWriter",
  ]
}
