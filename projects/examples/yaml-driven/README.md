# ==============================================================================
# EXAMPLE: projects module — YAML-driven usage
# ==============================================================================

This example demonstrates defining projects via a YAML configuration file
(`projects.yaml`) instead of inline Terraform blocks.

## Usage

```powershell
cd C:\Users\user\Document\Repositories\Finops-Project\projects\examples\yaml-driven

# Edit projects.yaml to define your projects, then:
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `billing_account_id` | GCP billing account ID | `01A325-032DBC-FAB4E4` |

## How it works

1. `main.tf` uses `yamldecode(file(...))` to read `projects.yaml` into a local
2. The local is iterated with a `for` expression and passed to the `projects`
   module
3. To add/remove projects, edit `projects.yaml` — no Terraform changes needed

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project key -> created project ID |
| `project_numbers` | Map of project key -> project number |

## Notes

- Project label values must be 1-63 characters, lowercase letters/digits/hyphens/underscores
- Periods (`.`) are NOT allowed in label values (e.g., `john.doe` will fail — use `john-doe` or `john_doe`)