# finops-budgets — Basic Example

Minimal example that creates a billing budget with scoping and IAM viewers.
## Usage

```hcl
module "finops_budgets" {
  source = "../../"

  billing_account          = "000000-000000-000000"
  pubsub_topic_id          = "projects/my-project/topics/finops-budget-alerts"
  notification_channel_ids = {}

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

  iam_viewers = ["group:finops-team@example.com"]
}
```

## Run

```bash
cd finops-budgets/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_billing_budget` — Real GCP billing budget with threshold rules
- `google_billing_account_iam_member` — Viewer grants for FinOps team

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `billing_account_id` | `string` | `"000000-000000-000000"` | GCP billing account ID |
| `pubsub_topic_id` | `string` | `"projects/my-project/topics/finops-budget-alerts"` | Full Pub/Sub topic ID from finops-alerts |
| `notification_channel_ids` | `map(string)` | `{}` | Map of email to notification channel ID from finops-alerts |
| `iam_viewers` | `list(string)` | `["group:finops-team@example.com"]` | Members granted billing.viewer role |

## Outputs

| Name | Description |
|------|-------------|
| `budget_ids` | Map of budget key to resource name |
| `budget_amounts` | Budget amount structs consumed by finops-dataset for the finops_budgets view |
