# host-projects — examples/basic

Minimal example of the host-projects module.

## Usage

```hcl
module "host_projects" {
  source = "../../"

  org_id             = "563019909339"
  billing_account_id = "01A325-032DBC-FAB4E4"
  terraform_user     = "user:sujalparashar007@gmail.com"

  projects = {
    network = {
      project_id   = "foundation-network"
      project_name = "Foundation Network"
      folder_name  = "folder-network"
    }
  }
}
```
