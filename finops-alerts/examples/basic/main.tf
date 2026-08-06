# Example: finops-alerts basic usage
# Creates a Pub/Sub topic for budget alerts and email notification channels.
# Run: terraform init && terraform validate

module "finops_alerts" {
  source = "../../"

  project_id   = var.project_id
  topic_name   = "finops-budget-alerts"
  alert_emails = var.alert_emails
}
