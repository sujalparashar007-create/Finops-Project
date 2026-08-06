variable "project_id" {
  description = "GCP project ID for the Pub/Sub topic and notification channels"
  type        = string
  default     = "my-project-id"
}

variable "alert_emails" {
  description = "Email addresses for budget alert notifications"
  type        = list(string)
  default     = ["alerts@example.com"]
}
