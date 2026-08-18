variable "hub_project_id" {
  description = "GCP project ID"
  type        = string
  default     = "example-hub-project"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "hub_name" {
  description = "NCC hub name"
  type        = string
  default     = "ncc-hub"
}

variable "vpc_spokes" {
  description = "Map of spoke name to object containing project_id and vpc_self_link"
  type = map(object({
    project_id    = string
    vpc_self_link = string
  }))
  default = {}
}

variable "labels" {
  description = "Labels to apply to NCC resources"
  type        = map(string)
  default     = {}
}
