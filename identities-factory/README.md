# identities-factory — YAML-Driven Service Account Factory

Reads one YAML file per service account from `factories/identities/` and
creates the SA plus its project-scoped role grants.

## Directory layout

```
identities-factory/
├── factories/
│   └── identities/
│       └── <account_id>.yaml (one per SA)
├── main.tf
└── ...
```

## YAML schema

```yaml
project_id: marketing-ecommerce-prod
display_name: "Runtime SA for ecommerce workload"
roles:
  - roles/logging.logWriter
  - roles/secretmanager.secretAccessor
```

## Usage

```hcl
module "identities_factory" {
  source = "../identities-factory"
}
```

## Inputs

None — all configuration is driven by YAML files.

## Outputs

| Name | Description |
|------|-------------|
| `emails` | Map of account_id -> SA email |
| `names` | Map of account_id -> SA fully-qualified resource name |

## Examples

See `examples/basic/` for a runnable root module.
