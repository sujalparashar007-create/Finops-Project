# ==============================================================================
# MODULE: projects — Landing-Zone GCP Project Creation
# ==============================================================================
# Creates one or more GCP projects with labels, folder placement, and API
# enablement. Project-level IAM is handled separately via the standalone
# `iam` module (scope = "project").
# ==============================================================================

resource "google_project" "this" {
  for_each = var.projects

  project_id      = each.key
  name            = each.key
  folder_id       = each.value.folder_id
  billing_account = var.billing_account_id
  labels          = each.value.labels
}

locals {
  project_apis_flat = merge([
    for project_id, p in var.projects : [
      for api in p.activate_apis : {
        "${project_id}::${api}" = {
          project_id = project_id
          api        = api
        }
      }
    ]
  ]...)
}

resource "google_project_service" "apis" {
  for_each = local.project_apis_flat

  project            = google_project.this[each.value.project_id].project_id
  service            = each.value.api
  disable_on_destroy = false
}
