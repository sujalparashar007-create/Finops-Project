# ==============================================================================
# MODULE: folder — GCP Folder Creation + Tags
# ==============================================================================
# Creates GCP folders and binds Resource Manager Tags. Folder-level IAM is
# handled separately via the standalone `iam` module (scope = "folder").
# ==============================================================================

resource "google_folder" "this" {
  for_each = var.folders

  display_name = each.key
  parent       = each.value.parent
}

# Bind pre-existing tag values to each folder resource.
locals {
  folder_tags_flat = merge([
    for folder_name, cfg in var.folders : {
      for tag_key, tag_value in cfg.tags : "${folder_name}::${tag_key}" => {
        folder_name = folder_name
        tag_value   = tag_value
      }
    }
  ]...)
}

resource "google_tags_tag_binding" "folder_tags" {
  for_each = local.folder_tags_flat

  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.this[each.value.folder_name].name}"
  tag_value = "tagValues/${each.value.tag_value}"
}
