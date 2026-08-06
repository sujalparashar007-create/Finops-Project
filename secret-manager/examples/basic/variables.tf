variable "project_id" {
  description = "GCP project ID for Secret Manager secrets"
  type        = string
  default     = "my-project-id"
}

variable "db_password" {
  description = "Database password to store in Secret Manager"
  type        = string
  sensitive   = true
  default     = ""
}

variable "api_key" {
  description = "API key to store in Secret Manager"
  type        = string
  sensitive   = true
  default     = ""
}
