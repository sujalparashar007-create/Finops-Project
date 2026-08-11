# ==============================================================================
# EXAMPLE: iam module — basic outputs
# ==============================================================================

output "scope" {
  description = "Scope this example was configured for."
  value       = module.project_iam.scope
}

output "resource_id" {
  description = "Resource ID this example was configured for."
  value       = module.project_iam.resource_id
}
