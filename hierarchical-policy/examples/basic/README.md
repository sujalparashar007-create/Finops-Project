# hierarchical-policy — Basic Example

Minimal example creating an org-level hierarchical firewall policy with 5 rules.

## Usage

```hcl
module "finops_org_policy" {
  source = "../../"
  org_id = "123456789"
  rules  = { ... }
}
```

## Run

```bash
cd hierarchical-policy/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_compute_firewall_policy` — Org-level hierarchical firewall policy
- `google_compute_firewall_policy_rule` — 5 declarative rules via for_each
- `google_compute_firewall_policy_association` — Attaches policy to organization

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `org_id` | `string` | `"123456789"` | GCP Organization ID (numeric) |

## Outputs

| Name | Description |
|------|-------------|
| `policy_id` | Full resource ID of the policy |
| `policy_name` | Short name of the policy |
