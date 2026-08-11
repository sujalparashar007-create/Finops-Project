# projects — Landing-Zone GCP Project Creation

Creates one or more GCP projects with labels, folder placement, and API
enablement. Project-level IAM is handled separately via the standalone `iam`
module (`scope = "project"`).

## Usage

```hcl
module "projects" {
  source = "../projects"

  billing_account_id = "01A325-032DBC-FAB4E4"

  projects = {
    "marketing-ecommerce-prod" = {
      folder_id = "123456789"
      activate_apis = [
        "cloudfunctions.googleapis.com",
        "secretmanager.googleapis.com",
      ]
      labels = {
        team        = "marketing"
        environment = "prod"
        cost_center = "12345"
        app         = "ecommerce"
        owner       = "john.doe"
        location    = "us"
      }
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `billing_account_id` | `string` | (required) | Billing account ID to link all projects to |
| `projects` | `map(object)` | (required) | Flat map of project configs |

### `projects` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder_id` | `string` | (required) | Parent folder ID |
| `activate_apis` | `list(string)` | `[]` | APIs to enable on this project |
| `labels.team` | `string` | (required) | Owning team |
| `labels.environment` | `string` | (required) | Environment (prod/staging/etc) |
| `labels.cost_center` | `string` | (required) | Cost center code |
| `labels.app` | `string` | (required) | Application name |
| `labels.owner` | `string` | (required) | Owner email or handle |
| `labels.location` | `string` | (required) | Primary location |

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project_id -> created GCP project ID |
| `project_numbers` | Map of project_id -> numeric project number |

## Examples

See `examples/basic/` for a runnable root module.
