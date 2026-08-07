output "budget_ids" {
  description = "Map of budget key to resource name"
  value       = { for k, v in google_billing_budget.budget : k => v.name }
}

output "budget_names" {
  description = "Map of budget key to display name"
  value       = { for k, v in google_billing_budget.budget : k => v.display_name }
}

output "budget_amounts" {
  description = "Budget amount structs consumed by finops-views to build the finops_budgets BigQuery view"
  value = flatten([
    for k, v in var.budgets : [
      for project in coalesce(
        try(v.budget_filter.projects, null),
        [try(v.budget_project, "projects/unknown")]
        ) : {
        month         = try(v.budget_month, "")
        project_id    = replace(project, "projects/", "")
        currency      = v.currency_code
        budget_amount = tonumber(v.units)
      }
    ] if try(v.budget_month, null) != null
  ])
}
