# ==============================================================================
# MODULE: finops-foundation — IAM + API Enablement for FinOps Projects
# ==============================================================================
# Encapsulates two concerns that are FinOps-stage-specific:
#
#   F7 — Additive project-level IAM grants (google_project_iam_member)
#   F13 — Consolidated API enablement (google_project_service)
#
# Usage:
#   module "finops_foundation" {
#     source = "../finops-foundation"
#     project_id    = "myco-finops-abc123"
#     activate_apis = ["billingbudgets.googleapis.com", ...]
#     iam           = { "roles/bigquery.admin" = ["serviceAccount:...@..."] }
#   }
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ENABLE APIs (F13 — one list, one for_each, no per-module duplication)
# ------------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = toset(var.activate_apis)

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# ------------------------------------------------------------------------------
# 2. PROJECT-LEVEL IAM (F7 — additive member grants per CFF pattern)
# ------------------------------------------------------------------------------
resource "google_project_iam_member" "members" {
  for_each = {
    for pair in flatten([
      for role, members in var.iam : [
        for member in members : { role = role, member = member }
      ]
    ]) : "${pair.role}/${pair.member}" => pair
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
