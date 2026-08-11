# ==============================================================================
# EXAMPLE: projects module — basic variables
# ==============================================================================

variable "billing_account_id" {
  description = "GCP billing account ID"
  type        = string
  default     = "01A325-032DBC-FAB4E4"
}

variable "folder_id" {
  description = "GCP Folder ID to create the project in"
  type        = string
  default     = "123456789"
}
