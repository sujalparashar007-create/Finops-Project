# ==============================================================================
# MODULE: finops-views — outputs
# ==============================================================================

output "view_ids" {
  description = "Map of view name to fully qualified table ID (project.dataset.view_name)"
  value       = { for k, v in google_bigquery_table.views : k => "${var.project_id}.${var.dataset_id}.${v.table_id}" }
}

output "project_id" {
  description = "GCP project ID (passthrough for downstream modules)"
  value       = var.project_id
}

output "dataset_id" {
  description = "BigQuery dataset ID (passthrough for downstream modules)"
  value       = var.dataset_id
}
