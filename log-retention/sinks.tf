resource "google_logging_project_sink" "project_sink" {
  for_each = var.parent_type == "project" ? local.sinks : {}

  name                   = each.key
  project                = var.parent
  destination            = each.value.destination_uri
  filter                 = each.value.filter
  description            = each.value.description
  disabled               = each.value.disabled
  unique_writer_identity = each.value.unique_writer_identity

  dynamic "bigquery_options" {
    for_each = each.value.destination_type == "bigquery" ? [each.value.bq_partitioned_tables] : []
    content {
      use_partitioned_tables = bigquery_options.value
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.key
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}

resource "google_logging_folder_sink" "folder_sink" {
  for_each = var.parent_type == "folder" ? local.sinks : {}

  name             = each.key
  folder           = var.parent
  destination      = each.value.destination_uri
  filter           = each.value.filter
  description      = each.value.description
  disabled         = each.value.disabled
  include_children = each.value.include_children

  dynamic "bigquery_options" {
    for_each = each.value.destination_type == "bigquery" ? [each.value.bq_partitioned_tables] : []
    content {
      use_partitioned_tables = bigquery_options.value
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.key
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}

resource "google_logging_organization_sink" "organization_sink" {
  for_each = var.parent_type == "organization" ? local.sinks : {}

  name             = each.key
  org_id           = var.parent
  destination      = each.value.destination_uri
  filter           = each.value.filter
  description      = each.value.description
  disabled         = each.value.disabled
  include_children = each.value.include_children

  dynamic "bigquery_options" {
    for_each = each.value.destination_type == "bigquery" ? [each.value.bq_partitioned_tables] : []
    content {
      use_partitioned_tables = bigquery_options.value
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.key
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}
