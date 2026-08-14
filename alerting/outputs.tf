output "notification_channel_ids" {
  description = "Map of channel name to notification channel resource ID."
  value = {
    for name, channel in google_monitoring_notification_channel.channels :
    name => channel.id
  }
}

output "alert_policy_ids" {
  description = "Map of policy name to alert policy resource ID."
  value = {
    for name, policy in google_monitoring_alert_policy.alerts :
    name => policy.id
  }
}
