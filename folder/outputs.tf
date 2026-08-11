# ==============================================================================
# MODULE: folder — outputs
# ==============================================================================

output "folder_ids" {
  description = "Map of folder display name to numeric folder ID"
  value       = { for k, v in google_folder.folders : k => v.folder_id }
}

output "folder_names" {
  description = "Map of folder display name to full resource name (folders/NNN)"
  value       = { for k, v in google_folder.folders : k => v.name }
}

output "folders" {
  description = "All folder resource objects (keyed by display name)"
  value       = google_folder.folders
}
