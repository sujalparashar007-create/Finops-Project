# ==============================================================================
# EXAMPLE: identities-factory module — basic usage
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
  # Apply with your own gcloud ADC credentials.
}

module "identities_factory" {
  source = "../../"
}