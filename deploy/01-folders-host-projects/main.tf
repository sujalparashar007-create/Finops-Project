# ==============================================================================
# STAGE 01: Folders + Host (Shared VPC host) Projects
# ==============================================================================
# Creates folders and the host projects that will host the hub & spoke VPCs.
# This is the first stage and MUST run with the human user's own credentials
# (no impersonation) because the tf-executor service accounts do not exist yet.
#
# Consumed by:
#   - 02-hub-spoke        -> project_ids, terraform_sa_emails
#   - 03-service-projects -> project_ids
# ==============================================================================

module "host_projects" {
  source = "../../host-projects"

  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  terraform_user     = var.terraform_user

  projects = var.projects
}
