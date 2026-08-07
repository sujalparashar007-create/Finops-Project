# ==============================================================================
# MODULE: finops-dataset — outputs
# ==============================================================================

output "dataset_id" {
  description = "BigQuery dataset ID — consumed by every downstream FinOps module"
  value       = local.dataset_id
}

output "project_id" {
  description = "GCP project ID where the dataset resides (passthrough for downstream modules)"
  value       = var.project_id
}

output "dataset_full_id" {
  description = "Fully qualified dataset reference (project.dataset) for view creation"
  value       = "${var.project_id}.${local.dataset_id}"
}
output "view_ids" {
  description = "Map of view name to fully qualified table ID (project.dataset.view_name)"
  value       = { for k, v in google_bigquery_table.views : k => "${var.project_id}.${local.dataset_id}.${v.table_id}" }
}
