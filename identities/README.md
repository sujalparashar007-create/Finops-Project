# identities — Service Account Factory

Creates Service Accounts and grants project-scoped roles to each. SAs have
their own lifecycle, independent of any one project's IAM, so they get
referenced by other modules (Cloud Functions, GKE workloads, WIF) after
creation.

## Usage

```hcl
module "identities" {
  source = "../identities"

  service_accounts = {
    "wl-ecommerce-sa" = {
      project_id   = "marketing-ecommerce-prod"
      display_name = "Runtime SA for ecommerce workload"
      roles        = ["roles/logging.logWriter", "roles/secretmanager.secretAccessor"]
    }
  }
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `service_accounts` | `map(object)` | Flat map of SAs: key = account_id, value = config |

### `service_accounts` object schema

| Attribute | Type | Description |
|-----------|------|-------------|
| `project_id` | `string` | Project where the SA is created |
| `display_name` | `string` | Human-readable SA name |
| `roles` | `list(string)` | Project-scoped roles granted to this SA |

## Outputs

| Name | Description |
|------|-------------|
| `emails` | Map of account_id -> SA email |
| `names` | Map of account_id -> SA fully-qualified resource name |

## Examples

See `examples/basic/` for a runnable root module.
