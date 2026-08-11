# ==============================================================================
# EXAMPLE: hierarchical-iam-factory module — basic usage
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

module "hier_iam_factory" {
  source = "../../"

  folders = {
    Production = {
      parent = "organizations/123456789012"
    }
  }
}