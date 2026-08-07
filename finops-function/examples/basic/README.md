# finops-function — Basic Example

Minimal example that deploys a Cloud Function (2nd gen) with Secret Manager credentials.
## Usage

```hcl
module "finops_function" {
  source = "../../"

  project_id      = "my-project-id"
  region          = "us-east1"
  pubsub_topic_id = "projects/my-project/topics/finops-budget-alerts"

  existing_service_account_email = "tf-executor@my-project.iam.gserviceaccount.com"

  environment_variables = {
    GMAIL_USER = "alerts@example.com"
  }

  secret_environment = {
    GMAIL_APP_PASSWORD = "your-app-password"
    TEAMS_WEBHOOK_URL  = "https://your-webhook-url"
  }
}
```

## Prerequisites

The API `secretmanager.googleapis.com` must be enabled on the target project.

## Run

```bash
cd finops-function/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_storage_bucket` — GCS bucket for function source code
- `google_cloudfunctions2_function` — Cloud Function 2nd gen with Pub/Sub trigger
- `google_secret_manager_secret` — Secrets for Gmail password and Teams webhook

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for the Cloud Function |
| `region` | `string` | `"us-east1"` | GCP region for the Cloud Function and GCS bucket |
| `pubsub_topic_id` | `string` | `"projects/my-project/topics/finops-budget-alerts"` | Full Pub/Sub topic ID to trigger the function |
| `function_source_dir` | `string` | `"./function-source"` | Path to directory containing main.py and requirements.txt |
| `bucket_name` | `string` | `"finops-function-source"` | GCS bucket name for storing function source code |
| `existing_service_account_email` | `string` | `"tf-executor@my-project.iam.gserviceaccount.com"` | Runtime SA (null = create dedicated SA) |
| `secret_environment` | `map(string)` | `{}` | Sensitive values stored in Secret Manager and exposed to the function |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Cloud Function name |
| `function_uri` | Cloud Function trigger URI |
| `bucket_name` | GCS bucket storing function source code |
