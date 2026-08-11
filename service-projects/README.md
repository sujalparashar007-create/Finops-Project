# service-projects - Service Project Factory

Creates one GCP service project for EACH host project and provisions a VM in each service project attached to its host's Shared VPC subnet. No folders are created - service projects belong to the requesting org.

## Usage

```hcl
module "service_projects" {
  source = "../service-projects"

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
      }
    }
  }
}
```

## Requirements

- Terraform 1.5+
- Google Provider 6.0+

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_id | GCP Organization ID (numeric) | string | n/a | yes |
| billing_account_id | GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX) | string | n/a | yes |
| terraform_user | Human user granted roles/iam.serviceAccountTokenCreator on the tf-executor SA | string | n/a | yes |
| hosts | Map of host project ID -> service project + VM. One service project created per host | map(object) | n/a | yes |
| service_project_sa_roles | IAM roles granted to the tf-executor SA in each service project | list(string) | 5 roles | no |

### `hosts` object structure

Key = host project ID (e.g. `foundation-network`)

| Field | Type | Description |
|-------|------|-------------|
| service_project_id | string | Service project GCP ID |
| service_project_name | string | Service project display name |
| vm.name | string | VM instance name |
| vm.machine_type | string | GCP machine type (e.g. e2-small) |
| vm.zone | string | GCP zone for the VM |
| vm.subnetwork_self_link | string | Host project shared subnet self link |
| vm.boot_image | string | Boot disk image (default debian-cloud/debian-12) |
| vm.tags | list(string) | Network tags (default []) |
| vm.metadata | map(string) | Instance metadata (default {}) |
| vm.external_ip | bool | Assign an external IP (default true) |

### Default `service_project_sa_roles`

| Role |
|------|
| `roles/compute.instanceAdmin` |
| `roles/compute.networkUser` |
| `roles/compute.securityAdmin` |
| `roles/storage.objectAdmin` |
| `roles/logging.logWriter` |

## Outputs (all keyed by host project ID)

| Name | Description |
|------|-------------|
| project_ids | Map of host ID to its service project GCP ID |
| project_names | Map of host ID to its service project name |
| terraform_sa_emails | Map of host ID to its service project tf-executor SA email |
| shared_vpc_attachment_ids | Map of host ID to Shared VPC attachment ID |
| vm_ids | Map of host ID to its service project VM self link |
| vm_names | Map of host ID to its service project VM name |
| vm_network_interfaces | Map of host ID to its service project VM external IP |
