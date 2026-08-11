# ==============================================================================
# EXAMPLE: hierarchical-iam-factory module — basic outputs
# ==============================================================================

output "folder_ids" {
  description = "Map of folder name -> folder ID"
  value       = module.hier_iam_factory.folder_ids
}

output "folder_names" {
  description = "Map of folder name -> folder resource name"
  value       = module.hier_iam_factory.folder_names
}