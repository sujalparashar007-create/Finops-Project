variable "hub_project_id" {
  description = "GCP project ID for the hub VPC"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "hub_cidr" {
  description = "CIDR reserved for the hub"
  type        = string
  default     = "10.0.0.0/20"
}

variable "hub_subnet_cidr" {
  description = "CIDR for the hub subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "hub_vpc_name" {
  description = "Name for the hub VPC"
  type        = string
  default     = "vpc-hub"
}

variable "hub_subnet_name" {
  description = "Name for the hub subnet"
  type        = string
  default     = "sb-hub"
}

variable "hub_router_name" {
  description = "Name for the hub Cloud Router"
  type        = string
  default     = "cr-hub"
}

variable "hub_router_asn" {
  description = "BGP ASN for the hub Cloud Router"
  type        = number
  default     = 64514
}

variable "spokes" {
  description = "Map of spoke VPCs to create"
  type = map(object({
    project_id                   = string
    region                       = optional(string)
    env_name                     = string
    spoke_cidr                   = string
    subnet_cidr                  = string
    vpc_name                     = optional(string, "vpc-spoke")
    subnet_name                  = optional(string, "sb-spoke")
    workload_type                = optional(string, "vm")
    pod_cidr                     = optional(string, "")
    svc_cidr                     = optional(string, "")
    peering_export_custom_routes = optional(bool, false)
    peering_import_custom_routes = optional(bool, false)
    firewall_rules = optional(map(object({
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
    })), {})
  }))
}

variable "firewall_rules" {
  description = "Firewall rules for the hub VPC"
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
}
