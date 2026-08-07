# ==============================================================================
# MODULE: finops-alerts â€” Spend Threshold Notifications (Module 3)
# ==============================================================================
# Creates Pub/Sub topic + email notification channels for budget alerts.
# The pubsub topic is wired into Module 2''s google_billing_budget so that
# threshold breaches publish events.
# ==============================================================================

locals {
  create_topic = var.existing_topic_id == null
  topic_id     = var.existing_topic_id != null ? var.existing_topic_id : google_pubsub_topic.budget_alerts[0].id
  topic_name   = var.existing_topic_id != null ? element(split("/", var.existing_topic_id), length(split("/", var.existing_topic_id)) - 1) : var.topic_name
}

# Pub/Sub topic for budget threshold events
resource "google_pubsub_topic" "budget_alerts" {
  count = local.create_topic ? 1 : 0

  project = var.project_id
  name    = var.topic_name

  labels = var.labels
}

# Email notification channels (skip emails with existing channel IDs)
resource "google_monitoring_notification_channel" "email" {
  for_each = toset([for e in var.alert_emails : e if !contains(keys(var.existing_notification_channel_ids), e)])

  project      = var.project_id
  display_name = "FinOps Budget Alert â€” ${each.key}"
  type         = "email"

  labels = {
    email_address = each.key
  }
}

# Additive IAM on the Pub/Sub topic (never authoritative — consistent with Fix 2)
resource "google_pubsub_topic_iam_member" "bindings" {
  for_each = { for entry in var.iam : "${entry.role}/${entry.member}" => entry }

  project = var.project_id
  topic   = local.topic_name
  role    = each.value.role
  member  = each.value.member
}
