output "metric_types" {
  description = "Map of sample metric name to fully qualified metric type."
  value       = module.samples.metric_types
}

output "dashboard_ids" {
  description = "Map of dashboard file name to dashboard resource ID."
  value       = module.samples.dashboard_ids
}

output "alert_policy_ids" {
  description = "Map of policy name to alert policy resource ID."
  value       = module.alerting.alert_policy_ids
}

output "bucket_ids" {
  description = "Map of bucket ID to fully qualified logging bucket resource ID."
  value       = module.log_retention.bucket_ids
}
