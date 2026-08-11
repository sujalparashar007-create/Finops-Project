# ==============================================================================
# EXAMPLE: custom-iam-roles module — basic usage
# ==============================================================================
# Run: cd examples/basic && terraform init && terraform apply
# ==============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # Uses your gcloud ADC credentials.
}

module "custom_roles" {
  source    = "../../"
  scope     = "project"
  project_id = var.project_id

  custom_roles = [{
    role_id     = "customSecretReaderNoList"
    title       = "Secret Reader (no list)"
    description = "Read secret versions without listing all secrets"
    permissions = ["secretmanager.versions.access"]
    stage       = "GA"
    reason      = "secretAccessor also grants list; this workload must not enumerate secret names."
  }]
}
