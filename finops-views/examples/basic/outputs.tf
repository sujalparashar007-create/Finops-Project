output "view_ids" {
  description = "Map of view name to fully qualified table ID"
  value       = module.finops_views.view_ids
}

output "monthly_kpi_summary_id" {
  description = "Fully qualified monthly_kpi_summary view ID for Looker Studio"
  value       = try(module.finops_views.view_ids["monthly_kpi_summary"], null)
}
