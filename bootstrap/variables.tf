# ==============================================================================
# ROOT MODULE: bootstrap — variables
# ==============================================================================

# --- REQUIRED ---

variable "project_id" {
  description = "GCP project ID (must be globally unique, 6-30 lowercase chars, digits, or hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "billing_account_id" {
  description = "GCP billing account ID to link the project to (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string

  validation {
    condition     = can(regex("^[A-F0-9]{6}-[A-F0-9]{6}-[A-F0-9]{6}$", var.billing_account_id))
    error_message = "billing_account_id must match pattern XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "terraform_user" {
  description = "Human user granted roles/iam.serviceAccountTokenCreator on the tf-executor SA so they can impersonate it. Must be prefixed with 'user:'."
  type        = string

  validation {
    condition     = can(regex("^user:", var.terraform_user))
    error_message = "terraform_user must be prefixed with 'user:'."
  }
}

variable "folder_id" {
  description = "GCP Folder ID (numeric)."
  type        = string
}

# --- OPTIONAL ---

variable "terraform_sa_name" {
  description = "Service account account_id for Terraform execution (used by 6-finops providers.tf)"
  type        = string
  default     = "tf-executor"
}

variable "terraform_sa_display_name" {
  description = "Display name for the Terraform service account"
  type        = string
  default     = "Terraform Executor SA"
}

variable "terraform_sa_roles" {
  description = "Project-level IAM roles granted to the tf-executor service account"
  type        = list(string)
  default = [
    "roles/bigquery.admin",
    "roles/pubsub.admin",
    "roles/monitoring.editor",
    "roles/storage.admin",
    "roles/cloudfunctions.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
    "roles/run.admin",
    "roles/eventarc.eventReceiver",
  ]
}

variable "activate_apis" {
  description = "Optional list of GCP APIs to enable on project creation"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
  ]
}

# --- MANDATORY PROJECT LABELS ---

variable "project_label_team" {
  description = "Label: owning team"
  type        = string
}

variable "project_label_environment" {
  description = "Label: environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "project_label_cost_center" {
  description = "Label: cost center code"
  type        = string
}

variable "project_label_app" {
  description = "Label: application name"
  type        = string
}

variable "project_label_owner" {
  description = "Label: owner email or handle"
  type        = string
}

variable "project_label_location" {
  description = "Label: primary location"
  type        = string
  default     = "us"
}