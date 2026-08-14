resource "google_monitoring_alert_policy" "alerts" {
  for_each = var.alert_policies

  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.key)
  combiner     = each.value.combiner
  enabled      = each.value.enabled
  severity     = each.value.severity
  user_labels  = each.value.user_labels

  # Resolve each reference to a channel created by this module, falling back to
  # the value as-is so callers can also pass full channel resource IDs.
  notification_channels = [
    for channel in each.value.notification_channels :
    try(google_monitoring_notification_channel.channels[channel].id, channel)
  ]

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = conditions.value.condition_threshold[*]
        content {
          filter          = condition_threshold.value.filter
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value
          duration        = condition_threshold.value.duration

          dynamic "aggregations" {
            for_each = condition_threshold.value.aggregation[*]
            content {
              alignment_period     = aggregations.value.alignment_period
              per_series_aligner   = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
              group_by_fields      = aggregations.value.group_by_fields
            }
          }
        }
      }

      dynamic "condition_matched_log" {
        for_each = conditions.value.condition_matched_log[*]
        content {
          filter           = condition_matched_log.value.filter
          label_extractors = condition_matched_log.value.label_extractors
        }
      }
    }
  }

  dynamic "documentation" {
    for_each = each.value.documentation[*]
    content {
      content   = documentation.value.content
      mime_type = documentation.value.mime_type
      subject   = documentation.value.subject
    }
  }
}
