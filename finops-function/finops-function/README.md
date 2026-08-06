# finops-function

Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts.
Secrets (Gmail app password, Teams webhook URL) are stored in Secret Manager.

## Usage

```hcl
module "finops_secrets" {
  source = "../secret-manager"

  project_id = "my-project-id"

  secrets = {
    "finops-budget-alert-processor-GMAIL_APP_PASSWORD" = var.gmail_app_password
    "finops-budget-alert-processor-TEAMS_WEBHOOK_URL"  = var.teams_webhook_url
  }

  accessors = [
    "serviceAccount:tf-executor@my-project.iam.gserviceaccount.com",
  ]
}

module "finops_function" {
  source = "../finops-function"

  project_id      = "my-project-id"
  region          = "us-east1"
  pubsub_topic_id = module.finops_alerts.pubsub_topic_id

  service_account_email = "tf-executor@my-project.iam.gserviceaccount.com"

  environment_variables = {
    GMAIL_USER = "alerts@example.com"
  }

  secret_environment = module.finops_secrets.secret_ids
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `pubsub_topic_id` | `string` | (required) | Full Pub/Sub topic ID to trigger the function |
| `region` | `string` | `"us-east1"` | GCP region |
| `function_name` | `string` | `"finops-budget-alert-processor"` | Cloud Function name |
| `function_source_dir` | `string` | `"function-source"` | Path to source code directory |
| `bucket_name` | `string` | `"finops-function-source"` | GCS bucket for source zip |
| `runtime` | `string` | `"python311"` | Cloud Function runtime |
| `service_account_email` | `string` | `""` | Runtime service account (defaults to tf-executor) |
| `max_instance_count` | `number` | `1` | Maximum number of Cloud Function instances |
| `available_memory` | `string` | `"256M"` | Memory allocated to the Cloud Function |
| `timeout_seconds` | `number` | `60` | Cloud Function execution timeout in seconds |

| `environment_variables` | `map(string)` | `{}` | Environment variables passed to the runtime (sensitive in Terraform) |
| `secret_environment` | `map(string)` | `{}` | Map of env var names → Secret Manager secret IDs (pass `module.finops_secrets.secret_ids` output) |
| `enable_function` | `bool` | `true` | Set to false to skip Cloud Function creation |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Cloud Function name |
| `function_uri` | Cloud Function trigger URI |
| `bucket_name` | GCS bucket storing function source code |
