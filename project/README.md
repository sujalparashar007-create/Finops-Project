# project — GCP Project Bootstrap (Stage 0)

Creates a GCP project with billing enabled, provisions the `tf-executor` service account, and grants all IAM roles required by the FinOps infrastructure (`6-finops`). Apply this module first, before any other FinOps Terraform configuration.

## Architecture

```
project module
├── google_project              # The GCP project + billing linkage
├── google_service_account      # tf-executor (impersonated by 6-finops/providers.tf)
├── google_project_iam_member   # 7 project-level roles for tf-executor
├── google_service_account_iam_member  # User → tokenCreator on tf-executor
└── google_billing_account_iam_member  # tf-executor → billing.admin
```

## Prerequisites

The user running `terraform apply` must have:

| Permission | Scope | Why |
|---|---|---|
| `roles/resourcemanager.projectCreator` | Org / Folder | Create the project |
| `roles/billing.user` | Billing Account | Link billing to the project |
| `roles/resourcemanager.projectIamAdmin` | Org / Folder | Grant project-level IAM |
| `roles/billing.admin` | Billing Account | Grant billing account IAM |
| `roles/iam.serviceAccountAdmin` | Project (after creation) | Create the tf-executor SA |

## Usage

```hcl
module "finops_project" {
  source = "../project"

  project_id         = "myco-finops-dev-abc123"
  project_name       = "FinOps Dev Project"
  billing_account_id = "01A325-032DBC-FAB4E4"
  org_id             = "563019909339"
  terraform_user     = "user:sujalparashar007@gmail.com"
}
```

## Post-Apply Manual Steps

1. **Enable billing export to BigQuery** on the billing account:
   - Console → Billing → Billing Export → BigQuery Export → Enable
   - Note the resulting `billing_export_table_id` — you'll need it in `6-finops/terraform.tfvars`

2. **Switch to impersonation** for all subsequent modules (`6-finops`, etc.):
   ```hcl
   # In your 6-finops/providers.tf or root provider block:
   provider "google" {
     project                     = "<project_id from output>"
     impersonate_service_account = "<terraform_sa_email from output>"
   }
   ```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID |
| `project_name` | `string` | (required) | Display name |
| `billing_account_id` | `string` | (required) | Billing account to link |
| `terraform_user` | `string` | (required) | User granted tokenCreator (prefixed `user:`) |
| `org_id` | `string` | `""` | Org ID (set this OR folder_id) |
| `folder_id` | `string` | `""` | Folder ID (set this OR org_id) |
| `terraform_sa_name` | `string` | `"tf-executor"` | SA account_id |
| `terraform_sa_display_name` | `string` | `"Terraform Executor SA"` | SA display name |
| `terraform_sa_roles` | `list(string)` | 7 roles (see below) | Project roles for tf-executor |
| `activate_apis` | `list(string)` | `[]` | Optional early API enablement |

### Default `terraform_sa_roles`

| Role |
|------|
| `roles/bigquery.admin` |
| `roles/pubsub.admin` |
| `roles/monitoring.editor` |
| `roles/storage.admin` |
| `roles/cloudfunctions.admin` |
| `roles/secretmanager.admin` |
| `roles/iam.serviceAccountUser` |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID |
| `project_number` | Numeric project number |
| `project_name` | Display name |
| `terraform_sa_email` | SA email (e.g. `tf-executor@PROJECT.iam.gserviceaccount.com`) |
| `terraform_sa_name` | Short SA account_id |
| `terraform_sa_id` | Full SA resource ID |
