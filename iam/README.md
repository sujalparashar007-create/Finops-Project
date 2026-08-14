# iam — Standalone Hierarchical IAM

Grants additive IAM member bindings at organization, folder, or project scope
using a single parameterized module. This module is intentionally "additive
only": it creates google_*_iam_member resources and never replaces or
authoritatively manages a role's full membership.

Key behaviors:
- Creates google_organization_iam_member, google_folder_iam_member, or
  google_project_iam_member depending on `scope`.
- Uses only additive member resources (never google_*_iam_binding or
  google_*_iam_policy) so it is safe to run alongside other IAM automation.

Usage example

```hcl
module "project_iam" {
  source      = "../iam"
  scope       = "project"
  resource_id = module.projects.project_ids["marketing-ecommerce-prod"]

  iam_bindings_additive = {
    app_owner = {
      member = "group:marketing-app-owners@example.com"
      role   = "roles/viewer"
    }
  }

  depends_on = [module.projects]
}
```

Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scope` | `string` | (required) | One of: `organization`, `folder`, or `project`. Controls which google_*_iam_member resource is created. |
| `resource_id` | `string` | (required) | The org ID, folder ID, or project ID to attach bindings to (matches `scope`). |
| `iam_bindings_additive` | `map(object)` | `{}` | Map of additive grants. Each entry must include `member` and `role` and may include an optional `condition` object. See Validation notes below. |
| `enable_conditional_bindings` | `bool` | `false` | When true, `condition` blocks (title/description/expression) included in entries are rendered into the IAM member resource. Default: `false`. |

Validation notes (important)

- Member format: the module validation requires members to be prefixed with one of: `group:`, `serviceAccount:`, or `domain:`. It intentionally disallows `user:` entries to avoid accidental user-scoped grants.
- Role format: roles must be either a predefined role `roles/<name>` or a custom role resource id such as `projects/<proj>/roles/<name>` or `organizations/<org>/roles/<name>`.
- Conditional bindings: include a `condition` object per entry only if `enable_conditional_bindings = true`. If `enable_conditional_bindings` is false any `condition` present in an entry is ignored by the dynamic block logic.

Permissions and caller requirements

- The identity running Terraform must have permission to add IAM members on the target resource. For project-scoped IAM this commonly requires `roles/resourcemanager.projectIamAdmin` or a role that can set project IAM members. For folder/org targets the caller needs the equivalent folder/org IAM management permission.

Outputs

| Name | Description |
|------|-------------|
| `scope` | Echoes the configured scope (organization|folder|project). |
| `resource_id` | Echoes the configured resource_id (org/folder/project ID). |

Example with conditional binding

```hcl
iam_bindings_additive = {
  conditional_viewer = {
    member = "group:viewers@example.com"
    role   = "roles/viewer"
    condition = {
      title       = "Restrict to production"
      description = "Only allow when resource.name ends_with prod"
      expression  = "resource.matchers[0] == 'prod'"
    }
  }
}
```

Notes

- This module intentionally avoids authoritative IAM inputs and binding resources so it will not remove memberships managed elsewhere.
- See `examples/basic/` for a minimal runnable example that targets projects.
