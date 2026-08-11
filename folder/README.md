# folder — GCP Folder Factory

Creates one or more GCP folders under a specified parent (organization or folder) with optional folder-level IAM bindings.

## Usage

```hcl
module "environment_folders" {
  source = "../folder"

  parent     = "organizations/123456789"
  names      = ["folder-network", "folder-development"]
  folder_iam_bindings = {
    dev_creator = {
      folder_key = "development"
      role       = "roles/resourcemanager.projectCreator"
      member     = "group:dev-team@example.com"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `parent` | `string` | (required) | Parent organization or folder |
| `names` | `list(string)` | `["network", "development"]` | Folder display names |
| `folder_iam_bindings` | `map(object)` | `{}` | Folder-level IAM bindings |

## Outputs

| Name | Description |
|------|-------------|
| `folder_ids` | Map of folder name to folder ID |
| `folder_names` | Map of folder name to full resource name |
| `folders` | All folder resource objects |


