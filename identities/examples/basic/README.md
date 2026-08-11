# identities/examples/basic — Standalone Service Account Creation

Applies the `identities` module to create a single service account and grant
project-scoped roles.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\identities\examples\basic

# Fill in your real project ID:
#   TF_VAR_project_id=my-project

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID where the SA is created |

## Outputs

| Name | Description |
|------|-------------|
| `emails` | Map of account_id -> SA email |
| `names` | Map of account_id -> SA fully-qualified resource name |
