variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "example-project"
}

variable "vpc_self_link" {
  description = "Self-link of the VPC network"
  type        = string
  default     = "projects/example-project/global/networks/my-vpc"
}
