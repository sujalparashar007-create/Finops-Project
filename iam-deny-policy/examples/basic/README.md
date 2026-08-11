# iam-deny-policy/examples/basic — Standalone Deny Policy

Applies the `iam-deny-policy` module to block all public access to a project.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\iam-deny-policy\examples\basic

# Fill in your real project ID:
#   TF_VAR_project_id=my-project

terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID to attach the deny policy to |

## Outputs

| Name | Description |
|------|-------------|
| `policy_name` | Full resource name of the deny policy |
| `parent` | Parent scope/target |

## Notes

- Deny policies are authoritative per (parent, name). If multiple teams need
  guardrails on the same target, each team must use a unique `policy_name`.
- GCP does not support resource-level deny policies — only org, folder, or
  project scope.
