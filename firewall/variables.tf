variable "project_id" {
  description = "GCP project ID where the VPC firewall rules will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}$", var.project_id))
    error_message = "project_id must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "vpc_self_link" {
  description = "Self-link of the VPC network to apply firewall rules to"
  type        = string
}

variable "rules" {
  description = "Map of firewall rules to create"
  type = map(object({
    name                    = string
    description             = optional(string, "")
    direction               = optional(string, "INGRESS")
    priority                = optional(number, 1000)
    source_ranges           = optional(list(string), [])
    destination_ranges      = optional(list(string), [])
    source_tags             = optional(list(string), [])
    target_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for key, rule in var.rules :
      contains(["INGRESS", "EGRESS"], rule.direction) &&
      rule.priority > 0 &&
      rule.priority < 65535
    ])
    error_message = "Each rule must have direction = 'INGRESS' or 'EGRESS' and priority between 1 and 65534."
  }
}