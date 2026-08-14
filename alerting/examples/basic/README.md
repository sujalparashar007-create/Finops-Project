# Basic example

Calls `alerting` to create one email notification channel and a log-match alert
policy that fires whenever a `SetIamPolicy` call is observed in the project's
audit logs.

## Usage

```bash
terraform init
terraform plan \
  -var="project_id=<your-project-id>" \
  -var="alert_email=<you@example.com>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the example channel and alert policy are created. | `string` | yes |
| alert_email | Email address that receives alert notifications. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| notification_channel_ids | Map of channel name to notification channel resource ID. |
| alert_policy_ids | Map of policy name to alert policy resource ID. |
