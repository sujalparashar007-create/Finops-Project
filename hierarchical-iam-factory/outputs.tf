# ==============================================================================
# MODULE: hierarchical-iam-factory — outputs
# ==============================================================================

output "folder_ids" {
  description = "Map of folder display name -> folder ID"
  value       = module.folders.folder_ids
}

output "folder_names" {
  description = "Map of folder display name -> folder resource name"
  value       = module.folders.folder_names
}