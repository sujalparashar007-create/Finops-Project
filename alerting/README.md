# alerting

Creates Cloud Monitoring **notification channels** and **alert policies** for a
project. Cloud Monitoring is per-project, so this module is project-scoped: its
alert policies are evaluated within the given project's metrics scope.

## What this module does

- Creates zero or more **notification channels**
  (`google_monitoring_notification_channel`) - email, SMS, Pub/Sub, Slack, etc.
- Creates zero or more **alert policies**
  (`google_monitoring_alert_policy`), each with one or more conditions and an
  optional documentation block for incident routing/runbooks.
- Lets an alert policy reference a channel created in this module by its map
  key, falling back to a raw channel ID if the reference is not a local key.

## Supported conditions

Each condition sets exactly one of:

- **`condition_threshold`** - metric threshold alerts (with an optional single
  `aggregation`).
- **`condition_matched_log`** - log-match alerts.

These cover the common landing-zone cases. Other condition types (MQL, PromQL,
absence) are intentionally not exposed yet; add them when a real use case needs
them.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "alerting" {
  source = "../alerting"

  project_id = "my-project"

  notification_channels = {
    "ops-email" = {
      type   = "email"
      labels = { email_address = "ops@example.com" }
    }
  }

  alert_policies = {
    "iam-policy-changes" = {
      display_name          = "IAM policy changes"
      notification_channels = ["ops-email"]
      conditions = [{
        display_name = "IAM setIamPolicy calls"
        condition_matched_log = {
          filter = "protoPayload.methodName=\"SetIamPolicy\""
        }
      }]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| project_id | Project ID where channels and policies are created. | `string` | n/a | yes |
| notification_channels | Map of notification channels, keyed by channel name. | `map(object)` | `{}` | no |
| alert_policies | Map of alert policies, keyed by policy name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| notification_channel_ids | Map of channel name to notification channel resource ID. |
| alert_policy_ids | Map of policy name to alert policy resource ID. |
