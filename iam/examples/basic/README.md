# iam/examples/basic — Standalone Project IAM

Applies the `iam` module (additive-only) to grant project-level IAM bindings. It ships with an empty `iam_bindings_additive = {}`, so by default `terraform apply` is a zero-impact smoke test; uncomment the sample binding in `main.tf` to create a real grant.

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
- Ships with `iam_bindings_additive = {}` so `terraform apply` is a no-op by default. Delete the `{}` and uncomment the sample grant in `main.tf` to actually create an IAM binding.
