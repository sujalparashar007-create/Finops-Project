# organization/examples/basic — Standalone Org Data + Tags

Applies the `organization` module to read org data and bind tags.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\organization\examples\basic

# Fill in your real values:
#   TF_VAR_org_id=123456789012

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `org_id` | GCP Organization ID |

## Outputs

| Name | Description |
|------|-------------|
| `org_id` | Organization ID |
| `org_name` | Organization display name |
