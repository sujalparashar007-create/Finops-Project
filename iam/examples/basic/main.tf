# ==============================================================================
# EXAMPLE: iam module — basic usage
# ==============================================================================
# Standalone root module that grants additive project-level IAM bindings.
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
  # For project-scoped IAM, the caller must already have projectIamAdmin.
}

module "project_iam" {
  source = "../../"

  scope       = "project"
  resource_id = var.project_id

  iam_bindings_additive = {
    viewer = {
      member = "group:gcp-viewers@example.com"
      role   = "roles/viewer"
    }
  }

  enable_conditional_bindings = false
}
