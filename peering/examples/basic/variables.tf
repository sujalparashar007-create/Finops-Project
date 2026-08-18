variable "hub_vpc_self_link" {
  description = "Self-link of the hub VPC"
  type        = string
  default     = "projects/example-hub-project/global/networks/hub-vpc"
}

variable "spoke_vpc_self_link" {
  description = "Self-link of the spoke VPC"
  type        = string
  default     = "projects/example-spoke-project/global/networks/spoke-vpc"
}

variable "env_name" {
  description = "Environment name for naming the peering"
  type        = string
  default     = "dev"
}

variable "export_custom_routes" {
  description = "Export custom routes from this side"
  type        = bool
  default     = false
}

variable "import_custom_routes" {
  description = "Import custom routes to this side"
  type        = bool
  default     = false
}
