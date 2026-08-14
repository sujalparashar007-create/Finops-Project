# Full logging-and-monitoring picture: sample metrics + dashboards feed an alert
# policy, while a log sink routes audit logs into an immutable log bucket.

module "samples" {
  source = "../.."

  project_id = var.project_id
}

module "log_retention" {
  source = "../../../log-retention"

  parent      = var.project_id
  parent_type = "project"

  buckets = {
    "audit-logs" = {
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

module "alerting" {
  source = "../../../alerting"

  project_id = var.project_id

  notification_channels = {
    "ops-email" = {
      type   = "email"
      labels = { email_address = var.alert_email }
    }
  }

  alert_policies = {
    "denied-firewall-spike" = {
      display_name          = "Denied firewall hits spike"
      notification_channels = ["ops-email"]
      documentation = {
        content = "Denied firewall hits exceeded the threshold. Investigate for scanning or misconfiguration."
      }
      conditions = [{
        display_name = "Denied firewall hits > 100 / 5m"
        condition_threshold = {
          filter          = <<-EOT
            resource.type="gce_subnetwork" AND metric.type="${module.samples.metric_types["denied-firewall-hits"]}"
          EOT
          comparison      = "COMPARISON_GT"
          threshold_value = 100
          duration        = "0s"
          aggregation = {
            alignment_period     = "300s"
            per_series_aligner   = "ALIGN_SUM"
            cross_series_reducer = "REDUCE_SUM"
          }
        }
      }]
    }
  }
}
