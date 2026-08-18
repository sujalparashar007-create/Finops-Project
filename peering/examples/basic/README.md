# Peering Module — Basic Example

This example demonstrates how to use the peering module to create bidirectional VPC Network Peering between a hub VPC and a spoke VPC.

## Usage

```hcl
module "peering" {
  source = "../../"

  hub_vpc_self_link   = "projects/example-hub-project/global/networks/hub-vpc"
  spoke_vpc_self_link = "projects/example-spoke-project/global/networks/spoke-vpc"
  env_name            = "dev"

  export_custom_routes = false
  import_custom_routes = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| hub_vpc_self_link | Self-link of the hub VPC | string | n/a | yes |
| spoke_vpc_self_link | Self-link of the spoke VPC | string | n/a | yes |
| env_name | Environment name for naming the peering | string | n/a | yes |
| export_custom_routes | Export custom routes from this side | bool | false | no |
| import_custom_routes | Import custom routes to this side | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| hub_peering_name | Name of the hub-to-spoke peering |
| spoke_peering_name | Name of the spoke-to-hub peering |