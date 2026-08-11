# iam/examples/basic — Standalone Project IAM

Applies the `iam` module to grant additive project-level IAM bindings.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\iam\examples\basic

# Fill in your real values in terraform.tfvars or set TF_VAR_ env vars:
#   TF_VAR_project_id=my-project

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID to grant IAM on |

## Outputs

| Name | Description |
|------|-------------|
| `scope` | Configured scope (`project`) |
| `resource_id` | Configured resource ID (the project ID) |

## Notes

- The caller must already have `roles/resourcemanager.projectIamAdmin` on the target project.
- Bindings are additive (`google_project_iam_member`) and safe alongside other automation.
