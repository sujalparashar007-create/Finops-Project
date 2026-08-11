# ==============================================================================
# EXAMPLE: projects module — basic usage
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

module "projects" {
  source = "../../"

  billing_account_id = var.billing_account_id

  projects = {
    "marketing-ecommerce-prod" = {
      folder_id = var.folder_id
      activate_apis = [
        "cloudfunctions.googleapis.com",
        "secretmanager.googleapis.com",
      ]
      labels = {
        team        = "marketing"
        environment = "prod"
        cost_center = "12345"
        app         = "ecommerce"
        owner       = "john.doe"
        location    = "us"
      }
    }
  }
}
