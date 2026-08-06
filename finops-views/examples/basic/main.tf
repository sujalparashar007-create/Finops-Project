# Example: finops-views basic usage
# Creates BigQuery views for FinOps reporting (daily_cost, monthly_kpi_summary, etc.)
# Run: terraform init && terraform validate

module "finops_views" {
  source = "../../"

  project_id = var.project_id
  dataset_id = var.dataset_id

  billing_export_table_id = var.billing_export_table_id

  budget_targets = var.budget_targets
}
