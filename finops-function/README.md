# finops-function

Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts.
Sensitive values (e.g. Teams webhook URL) are stored in Secret Manager.
The function processes budget threshold breaches and sends Adaptive Card
notifications to Microsoft Teams.

## Usage

```hcl
module "finops_function" {
  source = "../finops-function"

  project_id      = "my-project-id"
  region          = "us-east1"
  pubsub_topic_id = module.finops_alerts.pubsub_topic_id

  existing_service_account_email = "tf-executor@my-project.iam.gserviceaccount.com"

  secret_environment = {
    TEAMS_WEBHOOK_URL = var.teams_webhook_url
  }
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
| `existing_service_account_email` | `string` | `null` | Runtime SA; null = module creates dedicated SA |
| `runtime_sa_roles` | `list(string)` | `["roles/logging.logWriter"]` | IAM roles for the dedicated runtime SA |
| `max_instance_count` | `number` | `1` | Maximum number of Cloud Function instances |
| `available_memory` | `string` | `"256M"` | Memory allocated to the Cloud Function |
| `timeout_seconds` | `number` | `60` | Cloud Function execution timeout in seconds |
| `environment_variables` | `map(string)` | `{}` | Env vars passed to the runtime (sensitive in Terraform) |
| `secret_environment` | `map(string)` | `{}` | Secrets stored in Secret Manager and exposed to the function |
| `existing_secret_ids` | `map(string)` | `{}` | Key ? existing secret ID; keys present here skip secret creation |
| `secret_accessors` | `list(object({secret_key, member}))` | `[]` | Additional members granted secretAccessor on specific secrets |
| `enable_function` | `bool` | `true` | Set to false to skip Cloud Function creation |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Cloud Function name |
| `function_uri` | Cloud Function trigger URI |
| `bucket_name` | GCS bucket storing function source code |

