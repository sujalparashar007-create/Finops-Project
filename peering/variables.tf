variable "hub_vpc_self_link" {
  description = "Self-link of the hub VPC"
  type        = string
}

variable "spoke_vpc_self_link" {
  description = "Self-link of the spoke VPC"
  type        = string
}

variable "env_name" {
  description = "Environment name for naming the peering"
  type        = string
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
