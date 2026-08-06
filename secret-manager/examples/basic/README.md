# secret-manager — Basic Example

Minimal runnable example that creates two secrets and grants access to a service account.

## Usage

```hcl
module "secrets" {
  source = "../../"

  project_id = "my-project-id"

  secrets = {
    "my-app-db-password" = "your-password"
    "my-app-api-key"     = "your-api-key"
  }

  accessors = [
    "serviceAccount:my-function-sa@my-project-id.iam.gserviceaccount.com",
  ]
}
```

## Run

```bash
cd secret-manager/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_secret_manager_secret` — 2 secrets (my-app-db-password, my-app-api-key)
- `google_secret_manager_secret_version` — 1 version per secret with the provided payload
- `google_secret_manager_secret_iam_member` — `roles/secretmanager.secretAccessor` granted to the specified accessor on every secret

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID for Secret Manager secrets |
| `db_password` | `string` | `""` | Database password to store in Secret Manager (sensitive) |
| `api_key` | `string` | `""` | API key to store in Secret Manager (sensitive) |

## Outputs

| Name | Description |
|------|-------------|
| `secret_ids` | Map of secret key to secret_id — use in Cloud Function `secret_environment_variables` |
| `secret_names` | Map of secret key to full resource name (`projects/PROJECT/secrets/SECRET_ID`) |
