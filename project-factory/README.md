# project-factory — YAML-Driven Project + IAM Factory

Reads one YAML file per project from `factories/projects/` and creates the
project plus its project-level IAM grants. No `.tf` changes needed to
onboard a new project.

## Directory layout

```
project-factory/
├── factories/
│   └── projects/
│       ├── _defaults.yaml    (optional)
│       └── <project_id>.yaml (one per project)
├── main.tf
└── ...
```

## YAML schema

```yaml
project_id: marketing-ecommerce-prod
folder_id: "123456789"
activate_apis:
  - cloudfunctions.googleapis.com
  - secretmanager.googleapis.com
labels:
  team: marketing
  environment: prod
  cost_center: "12345"
  app: ecommerce
  owner: john.doe
  location: us

iam_bindings_additive:
  app_owner:
    member: "group:marketing-app-owners@example.com"
    role: "roles/viewer"
```

## Usage

```hcl
module "project_factory" {
  source = "../project-factory"

  billing_account_id = "01A325-032DBC-FAB4E4"
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `billing_account_id` | `string` | Billing account ID linked to all created projects |

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of project key -> created GCP project ID |
| `project_numbers` | Map of project key -> numeric project number |
| `iam_scopes` | Map of project key -> IAM module scope/resource_id |

## Examples

See `examples/basic/` for a runnable root module.
