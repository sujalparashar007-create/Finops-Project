# ==============================================================================
# ROOT MODULE: bootstrap — Stage 0 GCP Project + tf-executor Bootstrap
# ==============================================================================
# Creates a GCP project with billing, provisions the tf-executor service
# account, and wires up impersonation so 6-finops can run. Apply this FIRST,
# before any other FinOps Terraform configuration.
#
# IMPORTANT: Apply this module with your OWN credentials (gcloud auth
# application-default login), NOT impersonating tf-executor — it doesn't
# exist yet.
# ==============================================================================

## Steps

1. **Fill in `terraform.tfvars`** — copy the example and set your real values.
2. **Authenticate** with your own user credentials:
   ```powershell
   gcloud auth application-default login
   ```
3. **Apply:**
   ```powershell
   cd C:\Users\user\Document\Repos\Finops-Project\bootstrap
   terraform init
   terraform plan
   terraform apply
   ```
4. **After apply:** capture the `project_id` and `terraform_sa_email` outputs.
   - Enable billing export to BigQuery (Console only).
   - Configure `6-finops` to point at this project and impersonate the SA.

## What gets created

| Resource | Detail |
|----------|--------|
| GCP project | Linked to the billing account |
| `tf-executor` SA | In the new project |
| Project-level IAM | Roles from `terraform_sa_roles` granted to tf-executor |
| Billing IAM | tf-executor → `roles/billing.admin` |
| SA IAM | Your user → `roles/iam.serviceAccountTokenCreator` on tf-executor |
| APIs | Enabled per `activate_apis` |

## Inputs

See `variables.tf` for all inputs with types, defaults, and validation.
Key required inputs: `project_id`, `billing_account_id`, `terraform_user`,
`folder_id`, and the mandatory labels.

## Outputs

| Name | Use |
|------|-----|
| `project_id` | Pass to `6-finops` as `var.project_id` |
| `project_number` | Useful for billing export table references |
| `terraform_sa_email` | Used in `6-finops/providers.tf` for impersonation |
| `terraform_sa_id` | Full SA resource ID |

## Module dependencies

This root module composes:
- `../projects` — creates the project (landing-zone module)
- `../identities` — creates the tf-executor SA + its project roles
- Direct billing-account IAM and SA-IAM grants (bootstrap-specific)