variable "billing_account_id" {
  description = "GCP billing account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string
  default     = "000000-000000-000000"
}

variable "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID from finops-alerts"
  type        = string
  default     = "projects/my-project/topics/finops-budget-alerts"
}

variable "notification_channel_ids" {
  description = "Map of email to notification channel ID from finops-alerts"
  type        = map(string)
  default     = {}
}

variable "iam_viewers" {
  description = "Members to grant billing.viewer role"
  type        = list(string)
  default     = ["group:finops-team@example.com"]
}
