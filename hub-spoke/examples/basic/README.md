# hub-spoke - examples/basic

Minimal example of the hub-spoke main module. Creates a hub VPC plus one spoke VPC (dev) connected via VPC peering, with an allow-ssh firewall rule on the hub VPC.

## Usage

```hcl
module "hub_spoke" {
  source = "../../"

  hub_project_id    = "example-network"
  region            = "us-central1"
  domain            = "example"
  connectivity_type = "peering"

  spokes = {
    dev = {
      project_id  = "example-development"
      env_name    = "dev"
      spoke_cidr  = "10.16.0.0/16"
      subnet_cidr = "10.16.0.0/24"
    }
  }

  firewall_rules = {
    allow_ssh = {
      name          = "allow-ssh"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| hub_project_id | GCP project ID for the hub | string | example-network | no |
| region | GCP region | string | us-central1 | no |
| domain | Logical domain / environment name | string | example | no |
| connectivity_type | ncc or peering | string | peering | no |

## Outputs

| Name | Description |
|------|-------------|
| hub_vpc_self_link | Self-link of the hub VPC |
| spoke_vpc_self_links | Map of spoke name to VPC self-link |
| ncc_hub_id | NCC hub ID (empty when peering) |
| firewall_rule_ids | Map of firewall rule key to ID on the hub VPC |