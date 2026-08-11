# ==============================================================================
# MODULE: folder — outputs
# ==============================================================================

output "folder_ids" {
  description = "Map of folder display name -> folder ID"
  value       = { for k, v in google_folder.this : k => v.id }
}

output "folder_names" {
  description = "Map of folder display name -> folder resource name"
  value       = { for k, v in google_folder.this : k => v.name }
}
