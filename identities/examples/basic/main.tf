# ==============================================================================
# EXAMPLE: identities module — basic usage
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

module "identities" {
  source = "../../"

  service_accounts = {
    "wl-ecommerce-sa" = {
      project_id   = var.project_id
      display_name = "Runtime SA for ecommerce workload"
      roles = [
        "roles/logging.logWriter",
        "roles/secretmanager.secretAccessor",
      ]
    }
  }
}
