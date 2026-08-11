variable "org_id" {
  description = "GCP Organization ID (numeric)"
  type        = string
}

variable "billing_account_id" {
  description = "GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string
}

variable "terraform_user" {
  description = "User granted tokenCreator on the tf-executor SA"
  type        = string
}

variable "hosts" {
  description = "Map of host project ID -> service project + VM"
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
