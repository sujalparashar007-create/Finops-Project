# ==============================================================================
# MODULE: identities — Service Account Factory
# ==============================================================================
# Creates Service Accounts and grants project-scoped roles to each.
# ==============================================================================

resource "google_service_account" "sa" {
  for_each = var.service_accounts

  project      = each.value.project_id
  account_id   = each.key
  display_name = each.value.display_name
}

locals {
  sa_role_grants = merge([
    for sa_key, sa in var.service_accounts : {
      for role in sa.roles : "${sa_key}::${role}" => {
        sa_key     = sa_key
        role       = role
        project_id = sa.project_id
      }
    }
  ]...)
}

resource "google_project_iam_member" "sa_roles" {
  for_each = local.sa_role_grants

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_key].email}"
}
