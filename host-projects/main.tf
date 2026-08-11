# ==============================================================================
# MODULE: host-projects � Host Project Factory
# ==============================================================================
# Creates folders and GCP projects for host projects (Shared VPC hosts).
# Each project is created inside its own folder.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CREATE FOLDERS (one per project)
# ------------------------------------------------------------------------------
module "folders" {
  source = "../folder"

  parent = "organizations/${var.org_id}"
  names  = [for k, v in var.projects : v.folder_name]
}

# ------------------------------------------------------------------------------
# 2. CREATE PROJECTS (one per folder)
# ------------------------------------------------------------------------------
module "projects" {
  source = "../project"

  for_each = var.projects

  project_id         = each.value.project_id
  project_name       = each.value.project_name
  billing_account_id = var.billing_account_id
  org_id             = var.org_id
  folder_id          = module.folders.folder_ids[each.value.folder_name]
  terraform_user     = var.terraform_user
}
