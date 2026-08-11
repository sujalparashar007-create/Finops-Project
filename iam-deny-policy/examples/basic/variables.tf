# ==============================================================================
# EXAMPLE: iam-deny-policy module — basic variables
# ==============================================================================

variable "project_id" {
  description = "GCP project ID to attach the deny policy to"
  type        = string
}
