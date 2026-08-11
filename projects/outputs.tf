# ==============================================================================
# MODULE: projects — outputs
# ==============================================================================

output "project_ids" {
  description = "Map of project_id -> created GCP project ID"
  value       = { for k, v in google_project.this : k => v.project_id }
}

output "project_numbers" {
  description = "Map of project_id -> numeric project number"
  value       = { for k, v in google_project.this : k => v.number }
}
