# ==============================================================================
# MODULE: folder — GCP Folder Factory
# ==============================================================================
# Creates one or more folders under a given parent (organization or folder)
# with optional folder-level IAM bindings.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. FOLDERS
# ------------------------------------------------------------------------------
resource "google_folder" "folders" {
  for_each            = toset(var.names)
  display_name        = each.value
  parent              = var.parent
  deletion_protection = false
}

# ------------------------------------------------------------------------------
# 2. FOLDER-LEVEL IAM (optional)
# ------------------------------------------------------------------------------
resource "google_folder_iam_member" "bindings" {
  for_each = var.folder_iam_bindings

  folder = google_folder.folders[each.value.folder_key].name
  role   = each.value.role
  member = each.value.member
}
