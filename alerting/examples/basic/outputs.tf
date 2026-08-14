output "notification_channel_ids" {
  description = "Map of channel name to notification channel resource ID."
  value       = module.alerting.notification_channel_ids
}

output "alert_policy_ids" {
  description = "Map of policy name to alert policy resource ID."
  value       = module.alerting.alert_policy_ids
}
