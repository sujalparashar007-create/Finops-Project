# ==============================================================================
# MODULE: finops-dataset — BigQuery Dataset for FinOps Reporting
# ==============================================================================
# Creates a BigQuery dataset to host all FinOps reporting views, plus
# additive dataset-level IAM grants (google_bigquery_dataset_iam_member —
# never authoritative, so it won't silently remove grants made outside this
# module).
#
# Usage example:
#   module "finops_dataset" {
#     source = "../modules/finops-dataset"
#
#     project_id = "myco-finops-abc123"
#     dataset_id = "billing_export"
#     location   = "EU"
#     iam = {
#       "roles/bigquery.dataViewer" = [
#         "serviceAccount:dashboard-sa@myco-finops-abc123.iam.gserviceaccount.com",
#         "group:finops-team@example.com"
#       ]
#       "roles/bigquery.dataEditor" = [
#         "serviceAccount:etl-sa@myco-finops-abc123.iam.gserviceaccount.com"
#       ]
#     }
#   }
# ==============================================================================

locals {
  create_dataset = var.existing_dataset_id == null
  dataset_id     = var.existing_dataset_id != null ? var.existing_dataset_id : google_bigquery_dataset.finops[0].dataset_id
}

# ------------------------------------------------------------------------------
# 1. BIGQUERY DATASET
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset" "finops" {
  count = local.create_dataset ? 1 : 0

  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.location
  labels     = var.labels
}

# ------------------------------------------------------------------------------
# 2. DATASET-LEVEL IAM (additive — one member per role, never authoritative)
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset_iam_member" "bindings" {
  for_each = { for entry in var.iam : "${entry.role}/${entry.member}" => entry }

  project    = var.project_id
  dataset_id = local.dataset_id
  role       = each.value.role
  member     = each.value.member
}

# ------------------------------------------------------------------------------
# 3. BIGQUERY VIEWS (factory — gated by enable_views flag)
# ------------------------------------------------------------------------------
resource "google_bigquery_table" "views" {
  for_each = var.enable_views ? var.views : {}

  project       = var.project_id
  dataset_id    = local.dataset_id
  table_id      = each.key
  friendly_name = each.value.friendly_name

  view {
    query          = each.value.query
    use_legacy_sql = false
  }

  deletion_protection = false

  depends_on = [google_bigquery_dataset.finops]
}
