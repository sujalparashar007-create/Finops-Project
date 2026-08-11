# ==============================================================================
# MODULE: project-factory — outputs
# ==============================================================================

output "project_ids" {
  description = "Map of project key -> created GCP project ID"
  value       = module.projects.project_ids
}

output "project_numbers" {
  description = "Map of project key -> numeric project number"
  value       = module.projects.project_numbers
}

output "iam_scopes" {
  description = "Map of project key -> IAM module scope/resource_id"
  value = {
    for pid in keys(module.projects.project_ids) : pid => {
      scope       = "project"
      resource_id = module.projects.project_ids[pid]
    }
  }
}
