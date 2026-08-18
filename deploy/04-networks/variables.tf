variable "hub_project_id" {
  description = "GCP project ID for the hub VPC"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "domain" {
  description = "Logical domain / environment name used for naming shared resources (e.g., prod, dev, network)"
  type        = string
  default     = "prod"
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

variable "labels" {
  description = "Labels applied to NCC resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# API ENABLEMENT
# ------------------------------------------------------------------------------

variable "hub_activate_apis" {
  description = "List of GCP APIs to enable in the hub project before creating resources"
  type        = list(string)
  default     = ["compute.googleapis.com"]
}

variable "spoke_activate_apis" {
  description = "List of GCP APIs to enable in the spoke project(s) before creating resources"
  type        = list(string)
  default     = ["compute.googleapis.com"]
}

variable "service_project_activate_apis" {
  description = "List of GCP APIs to enable in the service project before creating resources"
  type        = list(string)
  default     = ["compute.googleapis.com"]
}

# ------------------------------------------------------------------------------
# SERVICE PROJECT (Shared VPC consumer for spoke)
# ------------------------------------------------------------------------------

variable "create_service_project" {
  description = "If true, create the service project via google_project resource"
  type        = bool
  default     = true
}

variable "service_project_id" {
  description = "GCP project ID for the service project that consumes the spoke Shared VPC"
  type        = string
}

variable "service_project_number" {
  description = "Project number of the service project (required when create_service_project is false)"
  type        = string
  default     = ""
}

variable "org_id" {
  description = "GCP Organization ID (required when create_service_project is true)"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "GCP Folder ID (alternative to org_id when create_service_project is true)"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "GCP Billing Account ID (required when create_service_project is true)"
  type        = string
  default     = ""

  validation {
    condition     = !var.create_service_project || var.billing_account != ""
    error_message = "billing_account must be provided when create_service_project is true."
  }
}

# ------------------------------------------------------------------------------
# VALIDATION VMs
# ------------------------------------------------------------------------------

variable "create_validation_vms" {
  description = "If true, create validation VMs in hub and spoke for bidirectional peering testing"
  type        = bool
  default     = true
}

variable "validation_spoke" {
  description = "Key from var.spokes indicating which spoke to attach the service project to"
  type        = string
  default     = "dev"
}

variable "hub_validation_vm_name" {
  description = "Name for the hub validation Compute Engine instance"
  type        = string
  default     = "vm-validation-hub"
}

variable "hub_validation_vm_machine_type" {
  description = "Machine type for the hub validation VM"
  type        = string
  default     = "e2-medium"
}

variable "hub_validation_vm_zone" {
  description = "Zone for the hub validation VM"
  type        = string
  default     = "us-central1-a"
}

variable "spoke_validation_vm_name" {
  description = "Name for the spoke validation Compute Engine instance (in service project)"
  type        = string
  default     = "vm-validation-spoke"
}

variable "spoke_validation_vm_machine_type" {
  description = "Machine type for the spoke validation VM"
  type        = string
  default     = "e2-medium"
}

variable "spoke_validation_vm_zone" {
  description = "Zone for the spoke validation VM"
  type        = string
  default     = "us-central1-a"
}

variable "validation_vm_image" {
  description = "Boot disk image for validation VMs"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "validation_vm_disk_size" {
  description = "Boot disk size in GB for validation VMs"
  type        = number
  default     = 10
}

variable "validation_vm_disk_type" {
  description = "Boot disk type for validation VMs"
  type        = string
  default     = "pd-balanced"
}
