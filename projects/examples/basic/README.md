# projects/examples/basic — Standalone Project Creation

Applies the `projects` module to create a single landing-zone GCP project.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\projects\examples\basic

# Fill in your real values in terraform.tfvars or set env vars:
#   TF_VAR_billing_account_id=01A325-032DBC-FAB4E4
#   TF_VAR_folder_id=123456789

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `billing_account_id` | GCP billing account ID |
| `folder_id` | GCP Folder ID to create the project in |

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project key -> created project ID |
| `project_numbers` | Map of project key -> project number |

## Notes

- Project-level IAM is not handled here — use the standalone `iam` module with `scope = "project"` for grants.
- APIs listed under `activate_apis` are enabled automatically.
