# folder — examples/basic

Minimal example of the folder module.

## Usage

```hcl
module "folders" {
  source = "../../"

  parent = "organizations/123456789"
  names  = ["network", "development"]
}
```
