# ==============================================================================
# EXAMPLE: project module — variables
# ==============================================================================

# --- REQUIRED — pre-filled with your real values ---

variable "project_id" {
  description = "GCP project ID (must be globally unique)"
  type        = string
  default     = "finops-foundation-test"
}

variable "project_name" {
  description = "Display name for the GCP project"
  type        = string
  default     = "FinOps Foundation Test Project"
}

variable "billing_account_id" {
  description = "GCP billing account ID"
  type        = string
  default     = "01A325-032DBC-FAB4E4"
}

variable "terraform_user" {
  description = "Human user for tokenCreator (prefixed with 'user:')"
  type        = string
  default     = "user:sujalparashar007@gmail.com"
}

# --- OPTIONAL ---

variable "org_id" {
  description = "GCP Organization ID (numeric). Leave empty to use folder_id."
  type        = string
  default     = "563019909339"
}

variable "folder_id" {
  description = "GCP Folder ID (numeric). Leave empty to use org_id."
  type        = string
  default     = ""
}

