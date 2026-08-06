# Example: secret-manager basic usage
# Creates two secrets and grants access to a service account.
# Run: terraform init && terraform validate
# Set TF_VAR_db_password and TF_VAR_api_key before applying.

provider "google" {
  project = var.project_id
}

module "secrets" {
  source = "../../"

  project_id = var.project_id

  secrets = {
    "my-app-db-password" = var.db_password
    "my-app-api-key"     = var.api_key
  }

  accessors = [
    "serviceAccount:my-function-sa@${var.project_id}.iam.gserviceaccount.com",
  ]
}
