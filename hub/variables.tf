# ==============================================================================
# MODULE: hub — variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID where the hub VPC will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}$", var.project_id))
    error_message = "project_id must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "region" {
  description = "Default GCP region for the hub"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+-[a-z0-9]+$", var.region))
    error_message = "region must be a valid GCP region (e.g., us-central1, us-east1)."
  }
}

variable "hub_cidr" {
  description = "CIDR block reserved for the hub (e.g. 10.0.0.0/20)"
  type        = string
  default     = "10.0.0.0/20"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.hub_cidr))
    error_message = "hub_cidr must be a valid CIDR block (e.g., 10.0.0.0/20)."
  }
}

variable "subnet_cidr" {
  description = "Primary hub subnet CIDR (first /24 carved from hub_cidr)"
  type        = string
  default     = "10.0.0.0/24"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_cidr))
    error_message = "subnet_cidr must be a valid CIDR block (e.g., 10.0.0.0/24)."
  }
}

variable "subnet_name" {
  description = "Name for the hub subnet"
  type        = string
  default     = "sb-hub"
}

variable "vpc_name" {
  description = "Name for the hub VPC"
  type        = string
  default     = "vpc-hub"
}

variable "router_name" {
  description = "Name for the Cloud Router"
  type        = string
  default     = "cr-hub"
}

variable "router_asn" {
  description = "BGP ASN for the Cloud Router"
  type        = number
  default     = 64514
  validation {
    condition     = var.router_asn >= 64512 && var.router_asn <= 65534 || var.router_asn >= 4200000000 && var.router_asn <= 4294967294
    error_message = "router_asn must be a valid private BGP ASN (64512-65534 or 4200000000-4294967294)."
  }
}
