# host-projects � Host Project Factory

Creates folders and GCP projects for host projects (Shared VPC hosts). Each project is created inside its own folder.

## Usage

```hcl
module "host_projects" {
  source = "../host-projects"

  org_id             = "563019909339"
  billing_account_id = "01A325-032DBC-FAB4E4"
  terraform_user     = "user:sujalparashar007@gmail.com"

  projects = {
    network = {
      project_id   = "foundation-network"
      project_name = "Foundation Network"
      folder_nameclea  = "folder-network"
    }
    development = {
      project_id   = "foundation-development"
      project_name = "Foundation Development"
      folder_name  = "folder-development"
    }
  }
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `org_id` | `string` | GCP Organization ID |
| `billing_account_id` | `string` | Billing Account ID |
| `terraform_user` | `string` | Human user for SA impersonation |
| `projects` | `map(object)` | Map of projects to create |

## Outputs

| Name | Description |
|------|-------------|
| `project_ids` | Map of logical name to GCP project ID |
| `project_names` | Map of logical name to project name |
| `terraform_sa_emails` | Map of logical name to tf-executor SA email |
| `folder_ids` | Map of folder name to folder ID |
| `folder_names` | Map of folder name to full resource name |
