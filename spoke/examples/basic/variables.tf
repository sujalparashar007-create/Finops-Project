variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "example-spoke-project"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "env_name" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "spoke_cidr" {
  description = "Spoke CIDR"
  type        = string
  default     = "10.16.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.16.0.0/24"
}

variable "workload_type" {
  description = "Workload type"
  type        = string
  default     = "vm"
}