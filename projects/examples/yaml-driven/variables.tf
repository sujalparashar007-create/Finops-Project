# ==============================================================================
# EXAMPLE: projects module — YAML-driven variables
# ==============================================================================

variable "billing_account_id" {
  description = "GCP billing account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string
  default     = "01A325-032DBC-FAB4E4"
}