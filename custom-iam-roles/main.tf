# ==============================================================================
# MODULE: custom-iam-roles — Custom Role Definitions
# ==============================================================================
# Creates custom role definitions at organization or project scope.
# ==============================================================================

locals {
  roles_by_key = { for r in var.custom_roles : r.role_id => r }
}

resource "google_organization_iam_custom_role" "role" {
  for_each = var.scope == "organization" ? local.roles_by_key : {}

  org_id      = var.org_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

resource "google_project_iam_custom_role" "role" {
  for_each = var.scope == "project" ? local.roles_by_key : {}

  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}
