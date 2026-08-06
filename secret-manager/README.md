# secret-manager — Secret Manager Secrets, Versions & IAM

Creates Secret Manager secrets with versioned payloads and grants `roles/secretmanager.secretAccessor` to specified members. Single-responsibility — no Cloud Function wiring, no consumer logic.

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

# Pass secret IDs to a Cloud Function module
module "finops_function" {
  source = "../finops-function"
  ...
  secret_environment = module.finops_secrets.secret_ids
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID for Secret Manager secrets |
| `secrets` | `map(string)` | `{}` | Map of secret IDs → payload values (sensitive) |
| `accessors` | `list(string)` | `[]` | Members granted `roles/secretmanager.secretAccessor` on every secret |

## Outputs

| Name | Description |
|------|-------------|
| `secret_ids` | Map of secret key → secret_id (short name) — use in Cloud Function `secret_environment_variables` |
| `secret_names` | Map of secret key → full resource name (`projects/PROJECT/secrets/SECRET_ID`) |
