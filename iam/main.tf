# ==============================================================================
# MODULE: iam — Standalone Hierarchical IAM
# ==============================================================================
# Grants IAM bindings at organization, folder, or project scope using a
# single parameterized module instead of duplicating logic across each
# resource module.
#
# Scope rules:
#   - scope = "organization" -> google_organization_iam_*
#   - scope = "folder"       -> google_folder_iam_*
#   - scope = "project"      -> google_project_iam_*
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
# 2. AUTHORITATIVE IAM BINDINGS (google_*_iam_binding) — var.iam
# ------------------------------------------------------------------------------
resource "google_organization_iam_binding" "authoritative" {
  for_each = local.is_org ? var.iam : {}

  org_id  = var.resource_id
  role    = each.key
  members = each.value
}

resource "google_folder_iam_binding" "authoritative" {
  for_each = local.is_folder ? var.iam : {}

  folder  = var.resource_id
  role    = each.key
  members = each.value
}

resource "google_project_iam_binding" "authoritative" {
  for_each = local.is_project ? var.iam : {}

  project = var.resource_id
  role    = each.key
  members = each.value
}

# ------------------------------------------------------------------------------
# 3. AUTHORITATIVE CONDITION-AWARE BINDINGS — var.iam_bindings
# ------------------------------------------------------------------------------
resource "google_organization_iam_binding" "conditional" {
  for_each = local.is_org ? var.iam_bindings : {}

  org_id = var.resource_id
  role   = each.value.role

  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_folder_iam_binding" "conditional" {
  for_each = local.is_folder ? var.iam_bindings : {}

  folder  = var.resource_id
  role    = each.value.role

  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_binding" "conditional" {
  for_each = local.is_project ? var.iam_bindings : {}

  project = var.resource_id
  role    = each.value.role

  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
