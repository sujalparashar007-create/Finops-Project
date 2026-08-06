# ==============================================================================
# MODULE: finops-dataset — BigQuery Dataset for FinOps Reporting
# ==============================================================================
# Creates a BigQuery dataset to host all FinOps reporting views, plus
# dataset-level IAM bindings for consumers (dashboard SA, FinOps team, etc.).
# Single responsibility — no views, no tables, no budgets in this module.
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

# ------------------------------------------------------------------------------
# 1. BIGQUERY DATASET
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset" "finops" {
  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.location
  labels     = var.labels
}

# ------------------------------------------------------------------------------
# 2. DATASET-LEVEL IAM BINDINGS
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset_iam_binding" "bindings" {
  for_each = var.iam

  project    = var.project_id
  dataset_id = google_bigquery_dataset.finops.dataset_id
  role       = each.key
  members    = each.value
}
