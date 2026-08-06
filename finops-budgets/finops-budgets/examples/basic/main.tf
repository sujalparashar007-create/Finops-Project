# Example: finops-budgets basic usage
# Creates billing budgets with scoping, IAM viewers, and outputs budget_amounts.
# Run: terraform init && terraform validate

module "finops_budgets" {
  source = "../../"

  billing_account          = var.billing_account_id
  pubsub_topic_id          = var.pubsub_topic_id
  notification_channel_ids = var.notification_channel_ids

  budgets = {
    monthly_overall = {
      display_name                    = "Monthly Overall Budget"
      currency_code                   = "USD"
      units                           = "1000"
      credit_types_treatment          = "EXCLUDE_ALL_CREDITS"
      enable_project_level_recipients = true
      budget_month                    = "2026-08"
      budget_project                  = "projects/my-project"
      threshold_rules = [
        { threshold_percent = 0.5 },
        { threshold_percent = 0.8 },
        { threshold_percent = 1.0 },
      ]
    }
  }

  iam_viewers = var.iam_viewers
}
