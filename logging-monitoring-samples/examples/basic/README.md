# Basic example

Wires the three logging & monitoring modules into one complete picture:

- `logging-monitoring-samples` creates the sample log-based metrics and the
  security-signals dashboard.
- `alerting` creates an email channel and a threshold alert on the
  `denied-firewall-hits` metric produced above.
- `log-retention` creates an immutable (`locked`) audit-log bucket and a sink
  that routes Cloud Audit logs into it.

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
| project_id | Project ID where the resources are created. | `string` | yes |
| alert_email | Email address that receives alert notifications. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| metric_types | Map of sample metric name to fully qualified metric type. |
| dashboard_ids | Map of dashboard file name to dashboard resource ID. |
| alert_policy_ids | Map of policy name to alert policy resource ID. |
| bucket_ids | Map of bucket ID to fully qualified logging bucket resource ID. |
