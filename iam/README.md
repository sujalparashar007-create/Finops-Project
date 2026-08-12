# iam — Standalone Hierarchical IAM

Grants **additive** IAM member bindings at organization, folder, or project
scope using a single parameterized module. This replaces the per-module `iam.tf`
topic files that previously lived inside `organization`, `folder`, and `project`.

## Additive-only

This module creates only `google_*_iam_member` resources (for organization,
folder, and project scope). It never creates `google_*_iam_binding`, never
accepts authoritative `iam` / `iam_bindings` inputs, and therefore **never
removes or overwrites** IAM permissions owned by other modules, teams, or
existing configurations.

## Removed (previously authoritative)

The following inputs were removed in the additive-only refactor and must no
longer be passed:

- `iam` (`map(list(string))`) — the authoritative role → members input.
- `iam_bindings` (`map(object)`) — the authoritative condition-aware bindings input.

IAM is now managed **only** via `iam_bindings_additive` (as `google_*_iam_member`).
This guarantees the module never removes or overwrites IAM granted by other
modules, teams, or existing configurations.

## Why a standalone module

IAM bindings are broken out into their own module so
callers explicitly sequence IAM after the target resource exists. This means
two module calls / two diffs per binding target instead of one, but it keeps
IAM logic centralized and consistent.

## Usage

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

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scope` | `string` | (required) | `organization`, `folder`, or `project` |
| `resource_id` | `string` | (required) | The org/folder/project ID matching `scope` |
| `iam_bindings_additive` | `map(object)` | `{}` | Additive member grants (safe alongside other automation; never replaces a role's full membership) |
| `enable_conditional_bindings` | `bool` | `false` | Render `condition` blocks when entries include one |

## Outputs

| Name | Description |
|------|-------------|
| `scope` | Echoes the configured scope |
| `resource_id` | Echoes the configured resource_id |

## Examples

See `examples/basic/` for a runnable root module that grants project-level
additive IAM.
