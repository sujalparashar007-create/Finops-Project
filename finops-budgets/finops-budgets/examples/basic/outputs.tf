output "budget_ids" {
  description = "Map of budget key to resource name"
  value       = module.finops_budgets.budget_ids
}

output "budget_amounts" {
  description = "Budget amount structs for finops-views"
  value       = module.finops_budgets.budget_amounts
}
