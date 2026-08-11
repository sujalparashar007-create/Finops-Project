# folder/examples/basic — Standalone Folder Creation

Applies the `folder` module to create two example folders under an organization.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\folder\examples\basic

# Fill in your real org ID in terraform.tfvars or set TF_VAR_org_id env var.
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
