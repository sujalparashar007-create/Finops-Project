output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.finops_dataset.dataset_id
}

output "project_id" {
  description = "GCP project ID hosting the FinOps views"
  value       = module.finops_dataset.project_id
}

output "dataset_full_id" {
  description = "Fully qualified dataset reference"
  value       = module.finops_dataset.dataset_full_id
}

output "view_ids" {
  description = "Map of view name to fully qualified table ID"
  value       = module.finops_views.view_ids
}

output "monthly_kpi_summary_id" {
  description = "Fully qualified monthly_kpi_summary view ID - use as data source in Looker Studio / Dashboard 1"
  value       = try(module.finops_views.view_ids["monthly_kpi_summary"], null)
}