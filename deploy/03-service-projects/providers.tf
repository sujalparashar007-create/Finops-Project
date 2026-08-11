# ==============================================================================
# STAGE 03: providers — impersonate the hub project's tf-executor SA
# ==============================================================================
provider "google" {
  region                      = var.region
  impersonate_service_account = local.terraform_sa_email
}
