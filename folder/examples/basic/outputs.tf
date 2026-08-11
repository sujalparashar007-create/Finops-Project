# ==============================================================================
# EXAMPLE: folder module — basic outputs
# ==============================================================================

output "folder_ids" {
  description = "Map of folder name -> folder ID"
  value       = module.folders.folder_ids
}

output "folder_names" {
  description = "Map of folder name -> folder resource name"
  value       = module.folders.folder_names
}
