# organization — GCP Organization Data + Tags

Represents the existing GCP Organization (data-only) and binds pre-existing
Resource Manager Tags to it. Org-level IAM is handled separately via the
standalone `iam` module (`scope = "organization"`).

## Usage

```hcl
module "org" {
  source = "../organization"

  org_id = "123456789012"

  tags = {
    "business-unit" = "tagValues/123456789"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `org_id` | `string` | (required) | GCP Organization ID |
| `tags` | `map(string)` | `{}` | Tag key short name -> tag value short name |

## Outputs

| Name | Description |
|------|-------------|
| `org_id` | GCP Organization ID |
| `org_name` | Organization display name |
| `directory_customer_id` | Directory customer ID |

## Examples

See `examples/basic/` for a runnable root module.
