# project-factory/examples/basic — YAML-Driven Project Factory

Applies the `project-factory` module to create projects from YAML definitions
in `factories/projects/`.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\project-factory\examples\basic

# Fill in your real billing account ID:
#   TF_VAR_billing_account_id=01A325-032DBC-FAB4E4

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `billing_account_id` | GCP billing account ID |

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project key -> created project ID |
| `project_numbers` | Map of project key -> project number |

## Notes

- Edit or add YAML files under `factories/projects/` to change what gets created.
- Each YAML file must have a unique filename matching its `project_id`.
- Project-level IAM is created per the `iam_bindings_additive` block in each YAML.
