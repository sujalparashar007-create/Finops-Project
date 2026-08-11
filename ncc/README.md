# NCC - Network Connectivity Center

Creates a central NCC hub and attaches VPC spokes to enable full-mesh connectivity across all attached VPCs without traditional VPC Peering.

## Usage

```hcl
module "ncc" {
  source = "../ncc"

  hub_project_id = "foundation-network"
  hub_name       = "ncc-hub"
  region         = "us-central1"

  vpc_spokes = {
    spoke-prod = {
      project_id    = "prod-project"
      vpc_self_link = "projects/prod-project/global/networks/prod-vpc"
    }
    spoke-dev = {
      project_id    = "dev-project"
      vpc_self_link = "projects/dev-project/global/networks/dev-vpc"
    }
  }

  labels = {
    env       = "prod"
    terraform = "true"
  }
}
```

## Requirements

- Terraform 1.5+
- Google Provider 6.0+

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| hub_project_id | GCP project ID where the NCC hub will be created | string | n/a | yes |
| hub_name | Name for the NCC hub | string | ncc-hub | no |
| region | GCP region (used for resource labels only; NCC hub and VPC spokes are global) | string | n/a | yes |
| vpc_spokes | Map of spoke name to object containing project_id and vpc_self_link | map(object) | n/a | yes |
| labels | Labels to apply to NCC resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| hub_id | ID of the NCC hub |
| hub_name | Name of the NCC hub |
| hub_state | Current state of the NCC hub |
| spoke_ids | Map of spoke name to NCC spoke resource ID |
| spoke_names | Map of spoke name to NCC spoke resource name |
