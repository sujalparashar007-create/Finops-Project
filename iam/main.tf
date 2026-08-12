# ==============================================================================
# MODULE: iam — Standalone Hierarchical IAM
# ==============================================================================
# Grants ADDITIVE IAM member bindings at organization, folder, or project
# scope using a single parameterized module instead of duplicating logic
# across each resource module.
#
# This module is additive-only: it creates `google_*_iam_member` resources
# (never `google_*_iam_binding`), so it never replaces a role's full
# membership and is safe to run alongside IAM changes made elsewhere.
#
# Scope rules:
#   - scope = "organization" -> google_organization_iam_member
#   - scope = "folder"       -> google_folder_iam_member
#   - scope = "project"      -> google_project_iam_member
# ==============================================================================

locals {
  is_org     = var.scope == "organization"
  is_folder  = var.scope == "folder"
  is_project = var.scope == "project"
}

# ------------------------------------------------------------------------------
# 1. ADDITIVE IAM BINDINGS (google_*_iam_member)
# ------------------------------------------------------------------------------
resource "google_organization_iam_member" "additive" {
  for_each = local.is_org ? var.iam_bindings_additive : {}

  org_id = var.resource_id
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_folder_iam_member" "additive" {
  for_each = local.is_folder ? var.iam_bindings_additive : {}

  folder = var.resource_id
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_member" "additive" {
  for_each = local.is_project ? var.iam_bindings_additive : {}

  project = var.resource_id
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# END: authoritative bindings intentionally omitted — this module is
# additive-only (creates google_*_iam_member for org/folder/project).
