# folder — GCP Folder Creation + Tags

Creates GCP folders and binds Resource Manager Tags. Folder-level IAM is
handled separately via the standalone `iam` module (`scope = "folder"`).

## Usage

```hcl
module "folders" {
  source = "../folder"

  folders = {
    Production = {
      parent = "organizations/123456789012"
      tags = {
        environment = "production"
      }
    }
    NonProduction = {
      parent = "organizations/123456789012"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `folders` | `map(object)` | (required) | Flat map of folder name -> config |

### `folders` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `parent` | `string` | (required) | Parent org/folder in `organizations/ID` or `folders/ID` form |
| `tags` | `map(string)` | `{}` | Tag key short name -> tag value short name |

## Outputs

| Name | Description |
|------|-------------|
| `folder_ids` | Map of folder display name -> folder ID |
| `folder_names` | Map of folder display name -> folder resource name |

## Examples

See `examples/basic/` for a runnable root module.
