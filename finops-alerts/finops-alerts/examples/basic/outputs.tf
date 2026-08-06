output "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID for wiring into finops-budgets"
  value       = module.finops_alerts.pubsub_topic_id
}

output "notification_channel_ids" {
  description = "Map of email to notification channel ID"
  value       = module.finops_alerts.notification_channel_ids
}
