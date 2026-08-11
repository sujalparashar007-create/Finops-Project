# Hub Module — Basic Example

This example demonstrates how to use the hub module to create a hub VPC, subnet, and Cloud Router.

## Usage

`hcl
module 'hub' {
  source = '../../'

  project_id  = 'foundation-network'
  region      = 'us-central1'
  hub_cidr    = '10.0.0.0/20'
  subnet_cidr = '10.0.0.0/24'
}
`, "
