# ==============================================================================
# MODULE: finops-alerts — outputs
# ==============================================================================

output "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID (projects/PROJECT/topics/NAME) for wiring into budgets"
  value       = google_pubsub_topic.budget_alerts.id
}

output "pubsub_topic_name" {
  description = "Pub/Sub topic name (short form)"
  value       = google_pubsub_topic.budget_alerts.name
}

output "notification_channel_ids" {
  description = "Map of email → notification channel ID"
  value       = { for k, v in google_monitoring_notification_channel.email : k => v.name }
}
