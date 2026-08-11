# ==============================================================================
# EXAMPLE: projects module — basic outputs
# ==============================================================================

output "project_ids" {
  description = "Map of project key -> created project ID"
  value       = module.projects.project_ids
}

output "project_numbers" {
  description = "Map of project key -> project number"
  value       = module.projects.project_numbers
}
