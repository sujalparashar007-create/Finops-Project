# project/examples/basic — Standalone Bootstrap

Applies the `project` module to create a new FinOps-ready GCP project from scratch. Variables are pre-filled with your real values — no editing required.

## Pre-Filled Values

| Variable | Value |
|---|---|
| `project_id` | `finops-foundation-test` |
| `project_name` | `FinOps Foundation Test Project` |
| `billing_account_id` | `01A325-032DBC-FAB4E4` |
| `org_id` | `563019909339` |
| `terraform_user` | `user:sujalparashar007@gmail.com` |

The module will create the project, link billing, provision the `tf-executor` service account, and grant all IAM roles needed by the `6-finops` root module (7 project-level roles + billing admin + token creator).

## Apply

```powershell
cd C:\Users\user\OneDrive\Documents\FINOPS-PROJECT\project\examples\basic
terraform init
terraform plan
terraform apply
```

**Note:** If `finops-foundation-test` is already taken, edit `variables.tf` line 10 and pick a different `project_id`.

## After Apply

### 1. Switch gcloud to the new project

```powershell
gcloud config set project finops-foundation-test
gcloud auth application-default login
```

### 2. Enable billing export to BigQuery (Console only)

GCP Console → **Billing** → **Billing Export** → **BigQuery Export** → select `finops-foundation-test` → **Enable**. Verify the resulting table name matches what's in `6-finops/terraform.tfvars` line 9. If the auto-generated table name differs, update it.

### 3. Deploy the FinOps infrastructure

The `6-finops/terraform.tfvars` and `budgets.yaml` files have already been updated to reference the new project. Run:

```powershell
cd C:\Users\user\OneDrive\Documents\FINOPS-PROJECT\6-finops

# Clean stale state from the deleted project
Remove-Item terraform.tfstate, terraform.tfstate.backup -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .terraform -ErrorAction SilentlyContinue

terraform init
terraform plan
terraform apply
```

## What Gets Created

| Resource | Detail |
|---|---|
| GCP Project | `finops-foundation-test` under org `563019909339` |
| `tf-executor` SA | 9 project-level IAM roles |
| SA IAM | Your user → `roles/iam.serviceAccountTokenCreator` on `tf-executor` |
| Billing IAM | `tf-executor` → `roles/billing.admin` on `01A325-032DBC-FAB4E4` |

## Outputs

| Output | Use |
|---|---|
| `project_id` | Pass to `6-finops` as `var.project_id` |
| `project_number` | Useful for billing export table references |
| `terraform_sa_email` | Used in `6-finops/providers.tf` for impersonation |
