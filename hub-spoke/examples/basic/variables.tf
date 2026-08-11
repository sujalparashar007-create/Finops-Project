variable "hub_project_id" {
  description = "GCP project ID for the hub"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "domain" {
  description = "Logical domain / environment name"
  type        = string
  default     = "prod"
}

variable "connectivity_type" {
  description = "ncc or peering"
  type        = string
  default     = "peering"
}