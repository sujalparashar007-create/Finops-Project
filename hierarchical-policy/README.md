# hierarchical-policy — Firewall Policy (Org | Folder | Project)

Creates firewall policies at any hierarchy level — configurable via `var.scope`.

## Usage

**Organization scope (hierarchical — inherited by all projects):**
```hcl
module "policy" {
  source = "../hierarchical-policy"
  scope  = "organization"
  org_id = "123456789"
  rules  = { ... }
}
```

**Folder scope (hierarchical — inherited by descendants):**
```hcl
module "policy" {
  source    = "../hierarchical-policy"
  scope     = "folder"
  folder_id = "987654321"
  rules     = { ... }
}
```

**Project scope (VPC firewall rules on a specific network):**
```hcl
module "policy" {
  source     = "../hierarchical-policy"
  scope      = "project"
  project_id = "my-proj"
  network    = "my-vpc"
  rules      = { ... }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scope` | `string` | (required) | `organization`, `folder`, or `project` |
| `org_id` | `string` | `""` | Org ID (required for org scope) |
| `folder_id` | `string` | `""` | Folder ID (required for folder scope) |
| `project_id` | `string` | `""` | Project ID (required for project scope) |
| `network` | `string` | `""` | VPC network name (required for project scope) |
| `policy_suffix` | `string` | `"foundation"` | Short suffix for policy name |
| `rules` | `map(object({...}))` | `{}` | Firewall rules — same structure across all scopes |

## Outputs

| Name | Description |
|------|-------------|
| `policy_id` | Policy ID (null for project scope) |
| `policy_name` | Policy name (null for project scope) |
