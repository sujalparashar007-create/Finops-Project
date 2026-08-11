variable "project_id" {
  description = "GCP project ID for the spoke VPC"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}$", var.project_id))
    error_message = "project_id must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+-[a-z0-9]+$", var.region))
    error_message = "region must be a valid GCP region (e.g., us-central1, us-east1)."
  }
}

variable "env_name" {
  description = "Environment name (dev/nonprod/prod)"
  type        = string
}

variable "spoke_cidr" {
  description = "CIDR block for the spoke (e.g. 10.16.0.0/16)"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", var.spoke_cidr))
    error_message = "spoke_cidr must be a valid CIDR block (e.g., 10.16.0.0/16)."
  }
}

variable "vpc_name" {
  description = "Name for the spoke VPC"
  type        = string
  default     = "vpc-spoke"
}

variable "subnet_name" {
  description = "Name for the primary subnet"
  type        = string
  default     = "sb-spoke"
}

variable "subnet_cidr" {
  description = "CIDR for the primary subnet"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", var.subnet_cidr))
    error_message = "subnet_cidr must be a valid CIDR block (e.g., 10.16.0.0/24)."
  }
}

variable "workload_type" {
  description = "Workload type: vm / gke / mixed"
  type        = string
  default     = "vm"
  validation {
    condition     = contains(["vm", "gke", "mixed"], var.workload_type)
    error_message = "workload_type must be vm, gke, or mixed"
  }
}

variable "pod_cidr" {
  description = "GKE pod secondary range CIDR"
  type        = string
  default     = ""
  validation {
    condition     = var.workload_type == "vm" ? true : can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", var.pod_cidr))
    error_message = "pod_cidr must be a valid CIDR block when workload_type is gke or mixed."
  }
}

variable "svc_cidr" {
  description = "GKE services secondary range CIDR"
  type        = string
  default     = ""
  validation {
    condition     = var.workload_type == "vm" ? true : can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", var.svc_cidr))
    error_message = "svc_cidr must be a valid CIDR block when workload_type is gke or mixed."
  }
}