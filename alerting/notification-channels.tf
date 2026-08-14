resource "google_monitoring_notification_channel" "channels" {
  for_each = var.notification_channels

  project      = var.project_id
  type         = each.value.type
  display_name = coalesce(each.value.display_name, each.key)
  description  = each.value.description
  enabled      = each.value.enabled
  labels       = each.value.labels
  user_labels  = each.value.user_labels
}
