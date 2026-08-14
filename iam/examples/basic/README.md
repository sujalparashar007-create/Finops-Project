# iam/examples/basic — Standalone Project IAM (example)

Minimal runnable root module demonstrating the `iam` module for project-scoped,
additive IAM grants. By default the example uses an empty `iam_bindings_additive = {}`
so `terraform apply` is a safe, zero-impact smoke test.

Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\iam\examples\basic

# Provide the example variable (via terraform.tfvars or env var):
#   TF_VAR_project_id=my-project-id

terraform init
terraform plan
terraform apply
```

Inputs

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP project ID to grant IAM on. Passed to the module as `resource_id`. |

Outputs

| Name | Description |
|------|-------------|
| `scope` | Always `project` for this example. |
| `resource_id` | The project ID that was targeted. |

Example binding snippet

Replace the empty map in `main.tf` with a real grant to create a binding, for
example:

```hcl
iam_bindings_additive = {
  viewer = {
    member = "group:gcp-viewers@example.com"
    role   = "roles/viewer"
  }
}
```

Conditional bindings

If you need IAM Conditions, set `enable_conditional_bindings = true` in the
module call and include a `condition` object per entry (title/description/expression).

Permissions

The identity running this example must be authorized to add IAM members on the
target project (e.g., `roles/resourcemanager.projectIamAdmin` or equivalent).

Notes

- This example demonstrates project-scoped additive IAM only. For folder or
  organization scope set `scope` and `resource_id` appropriately when calling
  the module.
- The example's `providers.tf` uses application-default credentials (gcloud ADC).
