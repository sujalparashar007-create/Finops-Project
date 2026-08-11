# custom-iam-roles — Custom Role Definitions

Creates custom role definitions at organization or project scope. A separate
module because role definitions have a different lifecycle from granting and
can be reused across many projects.

## Usage

```hcl
module "custom_roles" {
  source    = "../custom-iam-roles"
  scope     = "project"
  project_id = "marketing-ecommerce-prod"

  custom_roles = [{
    role_id     = "customSecretReaderNoList"
    title       = "Secret Reader (no list)"
    permissions = ["secretmanager.versions.access"]
    reason      = "secretAccessor also grants list; this workload must not enumerate secret names."
  }]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scope` | `string` | (required) | `organization` or `project` |
| `org_id` | `string` | `""` | Org ID (required when scope = organization) |
| `project_id` | `string` | `""` | Project ID (required when scope = project) |
| `custom_roles` | `list(object)` | `[]` | List of custom role definitions |

### `custom_roles` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `role_id` | `string` | (required) | Short role ID |
| `title` | `string` | (required) | Human-readable title |
| `description` | `string` | `""` | Role description |
| `permissions` | `list(string)` | (required) | Permissions list |
| `stage` | `string` | `"GA"` | Launch stage |
| `reason` | `string` | (required) | Why this custom role is needed (no predefined role fits) |

## Outputs

| Name | Description |
|------|-------------|
| `custom_role_ids` | Map of role_id -> fully-qualified custom role ID |

## Examples

See `examples/basic/` for a runnable root module.
