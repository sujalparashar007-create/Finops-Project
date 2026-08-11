# identities-factory/examples/basic — YAML-Driven Service Account Factory

Applies the `identities-factory` module to create service accounts from YAML
definitions in `factories/identities/`.

## Usage

```powershell
cd C:\Users\user\Document\Repos\Finops-Project\identities-factory\examples\basic

terraform init
terraform plan
terraform apply
```

## Inputs

None — all configuration is driven by YAML files under
`identities-factory/factories/identities/`.

## Outputs

| Name | Description |
|------|-------------|
| `emails` | Map of account_id -> SA email |
| `names` | Map of account_id -> SA fully-qualified resource name |

## Notes

- Add or edit YAML files under `factories/identities/` to change what gets created.
- Each YAML file's filename (minus `.yaml`) is the SA `account_id`.
- Each YAML must declare `project_id`, `display_name`, and `roles`.