# Basic example

Calls `log-retention` to create one immutable (`locked`) project-level log
bucket with 400-day retention and a sink that routes Cloud Audit logs into it.

## Usage

```bash
terraform init
terraform plan -var="project_id=<your-project-id>"
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| project_id | Project ID where the log bucket and sink are created. | `string` | yes |

## Outputs

| Name | Description |
|---|---|
| bucket_ids | Map of bucket ID to fully qualified logging bucket resource ID. |
| sink_writer_identities | Map of sink name to writer identity. |
