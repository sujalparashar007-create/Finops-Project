variable "project_id" {
  description = "Project ID where the sample metrics, dashboards, alert, and log bucket are created."
  type        = string
}

variable "alert_email" {
  description = "Email address that receives alert notifications."
  type        = string
}
