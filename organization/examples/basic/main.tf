# ==============================================================================
# EXAMPLE: organization module — basic usage
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

module "org" {
  source = "../../"

  org_id = var.org_id

  tags = {
    "business-unit" = "businesssvc"
  }
}
