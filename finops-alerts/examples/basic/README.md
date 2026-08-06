# finops-alerts — Basic Example

Minimal example that creates a Pub/Sub topic and email notification channels.
## Usage

```hcl
module "finops_alerts" {
  source = "../../"

  project_id   = "my-project-id"
  topic_name   = "finops-budget-alerts"
  alert_emails = ["alerts@example.com"]
}
```

## Run

```bash
cd finops-alerts/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_pubsub_topic` — Pub/Sub topic for budget alert events
- `google_monitoring_notification_channel` — Email notification channels

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for the Pub/Sub topic and notification channels |
| `alert_emails` | `list(string)` | `["alerts@example.com"]` | Email addresses for budget alert notifications |

## Outputs

| Name | Description |
|------|-------------|
| `pubsub_topic_id` | Full Pub/Sub topic ID for wiring into finops-budgets |
| `notification_channel_ids` | Map of email to notification channel ID |
