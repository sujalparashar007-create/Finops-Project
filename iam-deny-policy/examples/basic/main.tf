# ==============================================================================
# EXAMPLE: iam-deny-policy module — basic usage
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

module "deny_public_access" {
  source = "../../"

  scope       = "projects"
  target_id   = var.project_id
  policy_name = "deny-public-access"

  deny_rules = [{
    denied_principals  = ["principalSet://goog/public:all"]
    denied_permissions = ["*"]
    reason             = "Block all public access to this project by default."
  }]
}
