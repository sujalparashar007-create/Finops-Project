locals {
  # Sample dashboards are shipped as JSON files in the dashboards/ directory and
  # applied verbatim. Set create_dashboards = false to skip them.
  dashboard_files = var.create_dashboards ? fileset("${path.module}/dashboards", "*.json") : toset([])
}

resource "google_logging_metric" "metrics" {
  for_each = var.logging_metrics

  project          = var.project_id
  name             = each.key
  filter           = each.value.filter
  description      = each.value.description
  value_extractor  = each.value.value_extractor
  label_extractors = each.value.label_extractors

  dynamic "metric_descriptor" {
    for_each = each.value.metric_descriptor[*]
    content {
      metric_kind  = metric_descriptor.value.metric_kind
      value_type   = metric_descriptor.value.value_type
      display_name = metric_descriptor.value.display_name
      unit         = metric_descriptor.value.unit
    }
  }
}

resource "google_monitoring_dashboard" "dashboards" {
  for_each = local.dashboard_files

  project        = var.project_id
  dashboard_json = file("${path.module}/dashboards/${each.value}")
}
