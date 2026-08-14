resource "google_logging_project_bucket_config" "project_bucket" {
  for_each = var.parent_type == "project" ? var.buckets : {}

  project        = var.parent
  bucket_id      = each.key
  location       = each.value.location
  retention_days = each.value.retention_days
  locked         = each.value.locked
  description    = each.value.description

  dynamic "cmek_settings" {
    for_each = each.value.kms_key_name == null ? [] : [each.value.kms_key_name]
    content {
      kms_key_name = cmek_settings.value
    }
  }
}

resource "google_logging_folder_bucket_config" "folder_bucket" {
  for_each = var.parent_type == "folder" ? var.buckets : {}

  folder         = var.parent
  bucket_id      = each.key
  location       = each.value.location
  retention_days = each.value.retention_days
  description    = each.value.description
}

resource "google_logging_organization_bucket_config" "organization_bucket" {
  for_each = var.parent_type == "organization" ? var.buckets : {}

  organization   = var.parent
  bucket_id      = each.key
  location       = each.value.location
  retention_days = each.value.retention_days
  description    = each.value.description
}
