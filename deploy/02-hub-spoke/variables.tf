# ==============================================================================
# STAGE 02: variables
# ==============================================================================

variable "region" {
  description = "Default GCP region for hub and spoke resources"
  type        = string
}

variable "domain" {
  description = "Logical domain / environment name for naming shared resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.domain))
    error_message = "domain must contain only lowercase letters, digits, and hyphens."
  }
}

variable "connectivity_type" {
  description = "Connectivity method between hub and spokes: ncc or peering"
  type        = string
  default     = "peering"

  validation {
    condition     = contains(["ncc", "peering"], var.connectivity_type)
    error_message = "connectivity_type must be either ncc or peering."
  }
}

variable "hub_project_key" {
  description = "Logical key (from stage 01 projects) of the host project that owns the hub VPC"
  type        = string
  default     = "network"
}

# --- Hub overrides (optional, sensible defaults) ---

variable "hub_cidr" {
  description = "CIDR reserved for the hub VPC"
  type        = string
  default     = "10.0.0.0/20"
}

variable "hub_subnet_cidr" {
  description = "CIDR for the primary hub subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "hub_vpc_name" {
  description = "Hub VPC name"
  type        = string
  default     = "vpc-hub"
}

variable "hub_subnet_name" {
  description = "Hub subnet name"
  type        = string
  default     = "sb-hub"
}

variable "hub_router_name" {
  description = "Hub Cloud Router name"
  type        = string
  default     = "cr-hub"
}

variable "hub_router_asn" {
  description = "Hub Cloud Router BGP ASN"
  type        = number
  default     = 64514
}

# --- Spokes ---

variable "spokes" {
  description = "Map of spoke VPCs. Key = logical spoke name (shared as output key downstream). Value = { host_project_key, spoke_cidr, subnet_cidr, ... }."
  type = map(object({
    host_project_key             = string
    region                       = optional(string, "")
    env_name                     = optional(string, "")
    spoke_cidr                   = string
    subnet_cidr                  = string
    vpc_name                     = optional(string, "vpc-spoke")
    subnet_name                  = optional(string, "sb-spoke")
    workload_type                = optional(string, "vm")
    pod_cidr                     = optional(string, "")
    svc_cidr                     = optional(string, "")
    peering_export_custom_routes = optional(bool, false)
    peering_import_custom_routes = optional(bool, false)
  }))
}

# --- Firewall + labels ---

variable "firewall_rules" {
  description = "Map of firewall rules to apply to the hub VPC (see ../hub-spoke for schema)"
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

variable "labels" {
  description = "Labels applied to NCC resources"
  type        = map(string)
  default     = {}
}
