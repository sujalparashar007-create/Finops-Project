# ==============================================================================
# MODULE: finops-dataset — outputs
# ==============================================================================

output "dataset_id" {
  description = "BigQuery dataset ID — consumed by every downstream FinOps module"
  value       = google_bigquery_dataset.finops.dataset_id
}

output "project_id" {
  description = "GCP project ID where the dataset resides (passthrough for downstream modules)"
  value       = var.project_id
}

output "dataset_full_id" {
  description = "Fully qualified dataset reference (project.dataset) for view creation"
  value       = "${var.project_id}.${google_bigquery_dataset.finops.dataset_id}"
}
