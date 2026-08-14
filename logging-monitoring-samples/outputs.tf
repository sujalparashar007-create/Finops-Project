output "metric_ids" {
  description = "Map of metric name to log-based metric resource ID."
  value = {
    for name, metric in google_logging_metric.metrics :
    name => metric.id
  }
}

output "metric_types" {
  description = "Map of metric name to fully qualified metric type, for use in alert policy and dashboard filters."
  value = {
    for name, metric in google_logging_metric.metrics :
    name => "logging.googleapis.com/user/${metric.name}"
  }
}

output "dashboard_ids" {
  description = "Map of dashboard file name to dashboard resource ID."
  value = {
    for name, dashboard in google_monitoring_dashboard.dashboards :
    name => dashboard.id
  }
}
