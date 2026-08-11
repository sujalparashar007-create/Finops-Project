# ==============================================================================
# MODULE: hub-spoke - variables
# ==============================================================================

# --- REQUIRED ---

variable "hub_project_id" {
  description = "GCP project ID where the hub VPC, NCC hub, router, and firewall rules are created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.hub_project_id))
    error_message = "hub_project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "region" {
  description = "Default GCP region for hub and spoke resources (when a spoke does not set its own region)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+-[a-z0-9]+$", var.region))
    error_message = "region must be a valid GCP region (e.g., us-central1, us-east1)."
  }
}

variable "domain" {
  description = "Logical domain / environment name used for naming shared resources (e.g., prod, dev, network)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.domain))
    error_message = "domain must contain only lowercase letters, digits, and hyphens."
  }
}

variable "spokes" {
  description = "Map of spoke VPCs to create. Key = logical spoke name, value = { project_id, env_name, spoke_cidr, subnet_cidr, ... }"
  type = map(object({
    project_id                   = string
    region                       = optional(string, "")
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
  }))
}

# --- HUB OPTIONAL (have sensible defaults) ---

variable "hub_cidr" {
  description = "CIDR block reserved for the hub"
  type        = string
  default     = "10.0.0.0/20"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.hub_cidr))
    error_message = "hub_cidr must be a valid CIDR block (e.g., 10.0.0.0/20)."
  }
}

variable "hub_subnet_cidr" {
  description = "CIDR for the primary hub subnet"
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.hub_subnet_cidr))
    error_message = "hub_subnet_cidr must be a valid CIDR block (e.g., 10.0.0.0/24)."
  }
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

variable "connectivity_type" {
  description = "Connectivity method between hub and spokes: ncc (Network Connectivity Center) or peering (VPC peering)"
  type        = string
  default     = "peering"

  validation {
    condition     = contains(["ncc", "peering"], var.connectivity_type)
    error_message = "connectivity_type must be either ncc or peering."
  }
}

variable "firewall_rules" {
  description = "Map of firewall rules to apply to the hub VPC (see ../firewall for rule schema)"
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