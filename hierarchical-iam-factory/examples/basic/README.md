# hierarchical-iam-factory/examples/basic — YAML-Driven Hierarchical IAM

Applies the `hierarchical-iam-factory` module to create a folder and attach
folder-level IAM bindings from YAML definitions in `factories/hierarchical-iam/`.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\hierarchical-iam-factory\examples\basic

# Fill in your real org ID:
#   TF_VAR_org_id=123456789012

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `org_id` | GCP Organization ID (default: 123456789012) |

## Outputs

| Name | Description |
|------|-------------|
| `folder_ids` | Map of folder name -> folder ID |
| `folder_names` | Map of folder name -> folder resource name |

## Notes

- Add or edit YAML files under `factories/hierarchical-iam/` to change what gets created.
- The example creates a `Production` folder with a `gcp-prod-viewers` viewer grant.