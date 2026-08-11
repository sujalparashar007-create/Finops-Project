# service-projects - examples/basic

Minimal example of the service-projects module. Creates one service project (with a VM) for each host project under the Shared VPC.

## Usage

```hcl
module "service_projects" {
  source = "../../"

  org_id             = "563019909339"
  billing_account_id = "01A325-032DBC-FAB4E4"
  terraform_user     = "user:sujalparashar007@gmail.com"

  hosts = {
    foundation-network = {
      service_project_id   = "svc-network"
      service_project_name = "Network Service Project"
      vm = {
        name                 = "net-vm"
        machine_type         = "e2-small"
        zone                 = "us-central1-a"
        subnetwork_self_link = "projects/foundation-network/regions/us-central1/subnetworks/sb-hub"
        tags                 = ["network", "prod"]
      }
    }
    foundation-development = {
      service_project_id   = "svc-development"
      service_project_name = "Development Service Project"
      vm = {
        name                 = "dev-vm"
        machine_type         = "e2-medium"
        zone                 = "us-central1-b"
        subnetwork_self_link = "projects/foundation-development/regions/us-central1/subnetworks/sb-spoke"
        external_ip          = false
      }
    }
  }
}
```



## Outputs

- project_ids - map of host project ID to its service project GCP ID
- vm_names - map of host project ID to its service project VM name
- vm_network_interfaces - map of host project ID to its service project VM external IP
- shared_vpc_attachment_ids - map of host project ID to Shared VPC attachment ID
