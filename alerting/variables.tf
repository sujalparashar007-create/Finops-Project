variable "project_id" {
  description = "Project ID where notification channels and alert policies are created. Cloud Monitoring is per-project, so alerts are evaluated within this project's metrics scope."
  type        = string
}

variable "notification_channels" {
  description = "Notification channels to create, keyed by a descriptive channel name. The key can be referenced from an alert policy's notification_channels list."
  type = map(object({
    type         = string
    display_name = optional(string)
    description  = optional(string)
    enabled      = optional(bool, true)
    labels       = optional(map(string), {})
    user_labels  = optional(map(string), {})
  }))
  default = {}
}

variable "alert_policies" {
  description = "Alert policies to create, keyed by a descriptive policy name."
  type = map(object({
    display_name          = optional(string)
    combiner              = optional(string, "OR")
    enabled               = optional(bool, true)
    severity              = optional(string)
    user_labels           = optional(map(string), {})
    notification_channels = optional(list(string), [])
    documentation = optional(object({
      content   = string
      mime_type = optional(string, "text/markdown")
      subject   = optional(string)
    }))
    conditions = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter          = string
        comparison      = string
        threshold_value = optional(number)
        duration        = optional(string, "0s")
        aggregation = optional(object({
          alignment_period     = optional(string)
          per_series_aligner   = optional(string)
          cross_series_reducer = optional(string)
          group_by_fields      = optional(list(string))
        }))
      }))
      condition_matched_log = optional(object({
        filter           = string
        label_extractors = optional(map(string))
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for policy in var.alert_policies :
      contains(["AND", "OR", "AND_WITH_MATCHING_RESOURCE"], policy.combiner)
    ])
    error_message = "Every alert policy's combiner must be one of \"AND\", \"OR\", or \"AND_WITH_MATCHING_RESOURCE\"."
  }

  validation {
    condition = alltrue([
      for policy in var.alert_policies : alltrue([
        for condition in policy.conditions :
        (condition.condition_threshold != null) != (condition.condition_matched_log != null)
      ])
    ])
    error_message = "Every condition must set exactly one of condition_threshold or condition_matched_log."
  }
}
