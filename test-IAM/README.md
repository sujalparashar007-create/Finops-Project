# ==============================================================================
# ROOT MODULE: bootstrap — Stage 0 GCP Project + tf-executor Bootstrap
# ==============================================================================
# Creates a GCP project with billing, provisions the tf-executor service
# account, and wires up impersonation so test-finops can run. Apply this FIRST,
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
   cd C:\Users\user\Document\Repos\Finops-Project\test-IAM
   terraform init
   terraform plan
   terraform apply
   ```
4. **After apply:** capture the `project_id` and `terraform_sa_email` outputs.
   - Enable billing export to BigQuery (Console only).
   - Configure `test-finops` to point at this project and impersonate the SA.

## What gets created

| Resource | Detail |
|----------|--------|
| GCP project | Linked to the billing account |
| `tf-executor` SA | In the new project |
| Project-level IAM | Roles from `terraform_sa_roles` granted to tf-executor |
| Billing IAM | tf-executor → `roles/billing.admin` |
| SA IAM | Your user → `roles/iam.serviceAccountTokenCreator` on tf-executor |
| APIs | Enabled per `activate_apis` |
| FinOps projects (+ project IAM) | From `projects.yaml` (was `project-factory`) |
| FinOps service accounts (+ roles) | From `identities.yaml` (was `identities-factory`) |
| FinOps folders + folder-level IAM | From `hierarchical-iam.yaml` (was `hierarchical-iam-factory`) |
| Factory SA creation permission bootstrap | Grants `terraform_user` `roles/iam.serviceAccountAdmin` on each YAML-defined factory project so factory SAs can be created reliably |

## Factory configuration (YAML)

The three former factory modules (`project-factory`, `identities-factory`,
`hierarchical-iam-factory`) have been consolidated into bootstrap. Their
YAML-driven resources are now defined in top-level YAML files in this module
and created as part of the bootstrap deployment — no separate factory modules
remain.

| File | Purpose |
|------|---------|
| `projects.yaml` | FinOps projects + per-project additive IAM under `projects:` |
| `identities.yaml` | FinOps service accounts + roles under `service_accounts:` |
| `hierarchical-iam.yaml` | FinOps folders under `folders:` + folder IAM under `hierarchical_iam:` |

Edit any of these files and re-run `terraform apply` to change what gets
created — no Terraform code changes are needed for the factory resources.

## Inputs

See `variables.tf` for all inputs with types, defaults, and validation.
Key required inputs: `project_id`, `billing_account_id`, `terraform_user`,
`folder_id`, and the mandatory labels.

## Outputs

| Name | Use |
|------|-----|
| `project_id` | Pass to `test-finops` as `var.project_id` |
| `project_number` | Useful for billing export table references |
| `terraform_sa_email` | Used in `test-finops/providers.tf` for impersonation |
| `terraform_sa_id` | Full SA resource ID |
| `factory_project_ids` / `factory_project_numbers` / `factory_iam_scopes` | FinOps factory projects (project-factory outputs) |
| `factory_sa_emails` / `factory_sa_names` | FinOps factory service accounts (identities-factory outputs) |
| `factory_folder_ids` / `factory_folder_names` | FinOps factory folders (hierarchical-iam-factory outputs) |

## Module dependencies

This root module composes:
- `../projects` — creates the project (landing-zone module), once for the
  bootstrap host project and again via `module.factory_projects` for the
  YAML-driven FinOps projects
- `../identities` — creates the tf-executor SA + its project roles, and again
  via `module.factory_identities` for the YAML-driven FinOps SAs
- `../folder` — via `module.factory_folders` for the YAML-driven FinOps folders
- `../iam` — via `module.factory_project_iam` and `module.factory_folder_iam`
  for the YAML-driven project/folder additive IAM
- Direct billing-account IAM and SA-IAM grants (bootstrap-specific)