module "log_retention" {
  source = "../.."

  parent      = var.project_id
  parent_type = "project"

  buckets = {
    "audit-logs" = {
      location       = "global"
      retention_days = 400
      locked         = true
      description    = "Immutable bucket for audit logs (Terraform-managed)."
    }
  }

  sinks = {
    "audit-to-bucket" = {
      destination_type = "logging"
      destination      = "projects/${var.project_id}/locations/global/buckets/audit-logs"
      filter           = "logName:\"cloudaudit.googleapis.com\""
      description      = "Route audit logs to the immutable audit-logs bucket."
    }
  }
}
