# hub — Hub VPC, Subnet, and Cloud Router

Creates a hub VPC with a single subnet and a Cloud Router for hub-and-spoke networking.

## Usage

`hcl
module 'hub' {
  source = '../hub'

  project_id  = 'foundation-network'
  region      = 'us-central1'
  hub_cidr    = '10.0.0.0/20'
  subnet_cidr = '10.0.0.0/24'
}
`, "
