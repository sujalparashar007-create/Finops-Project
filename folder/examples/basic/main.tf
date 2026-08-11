# ==============================================================================
# EXAMPLE: folder module — basic usage
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
  # Caller needs folders.create at the parent org.
}

module "folders" {
  source = "../../"

  folders = {
    Production = {
      parent = "organizations/123456789012"
      tags = {
        environment = "production"
      }
    }
    NonProduction = {
      parent = "organizations/123456789012"
    }
  }
}
