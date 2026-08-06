output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.finops_dataset.dataset_id
}

output "dataset_full_id" {
  description = "Fully qualified dataset reference (project.dataset)"
  value       = module.finops_dataset.dataset_full_id
}
