# ==============================================================================
# EXAMPLE: project-factory module — basic outputs
# ==============================================================================

output "project_ids" {
  description = "Map of project key -> created project ID"
  value       = module.project_factory.project_ids
}

output "project_numbers" {
  description = "Map of project key -> project number"
  value       = module.project_factory.project_numbers
}
