# custom-iam-roles/examples/basic — Standalone Custom Role Creation

Applies the `custom-iam-roles` module to create a single project-scoped custom
role.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\custom-iam-roles\examples\basic

# Fill in your real project ID:
#   TF_VAR_project_id=my-project

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID where the custom role is defined |

## Outputs

| Name | Description |
|------|-------------|
| `custom_role_ids` | Map of role_id -> fully-qualified custom role ID |

## Notes

- Custom role definitions are rare by design — create one only after confirming no predefined role fits.
- Each custom role must document a `reason` explaining why it exists.
