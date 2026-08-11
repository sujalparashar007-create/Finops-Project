# hierarchical-iam-factory — YAML-Driven Folder/Org IAM Factory

Creates folders and folder-level IAM bindings from YAML. Used to scale
hierarchical IAM without editing Terraform code for every folder/binding.

## Directory layout

```
hierarchical-iam-factory/
├── factories/
│   └── hierarchical-iam/
│       └── <folder_name>.yaml (one per folder binding group)
├── main.tf
└── ...
```

## YAML schema

```yaml
folder_name: Production
bindings:
  prod_viewer:
    member: "group:gcp-prod-viewers@example.com"
    role: "roles/viewer"
```

## Usage

```hcl
module "hier_iam_factory" {
  source = "../hierarchical-iam-factory"

  folders = {
    Production = {
      parent = "organizations/123456789012"
    }
  }
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `folders` | `map(object)` | Flat map of folders to create, passed through to the `folder` module |

### `folders` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `parent` | `string` | (required) | Parent org/folder |
| `tags` | `map(string)` | `{}` | Tags to bind |

## Outputs

| Name | Description |
|------|-------------|
| `folder_ids` | Map of folder display name -> folder ID |
| `folder_names` | Map of folder display name -> folder resource name |

## Examples

See `examples/basic/` for a runnable root module.