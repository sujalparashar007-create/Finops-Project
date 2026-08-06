# ==============================================================================
# MODULE: finops-alerts â€” Spend Threshold Notifications (Module 3)
# ==============================================================================
# Creates Pub/Sub topic + email notification channels for budget alerts.
# The pubsub topic is wired into Module 2''s google_billing_budget so that
# threshold breaches publish events.
# ==============================================================================

# Pub/Sub topic for budget threshold events
resource "google_pubsub_topic" "budget_alerts" {
  project = var.project_id
  name    = var.topic_name

  labels = var.labels
}

# Email notification channel
resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.alert_emails)

  project      = var.project_id
  display_name = "FinOps Budget Alert â€” ${each.key}"
  type         = "email"

  labels = {
    email_address = each.key
  }
}
