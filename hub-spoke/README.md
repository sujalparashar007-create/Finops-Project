# hub-spoke - Main Hub-and-Spoke Networking Module

The main networking module for the project. Orchestrates the full hub-and-spoke topology: hub VPC, spoke VPCs, connectivity (NCC or VPC peering), and firewall rules on both hub and spoke VPCs.

## Architecture

```
hub-spoke (orchestrator)
├─ hub       → hub VPC + subnet + Cloud Router
├─ spokes    → one or more spoke VPCs + subnets
├─ ncc       → Network Connectivity Center (full-mesh, 2+ spokes)
├─ peering   → classic VPC peering (per spoke pair)
├─ firewall  → firewall rules on the hub VPC
└─ firewall_spoke → firewall rules on each spoke VPC
```

Choose connectivity via `connectivity_type`:
- `peering` - classic bidirectional VPC Network Peering (default)
- `ncc` - Network Connectivity Center hub-and-spoke (alternative, full-mesh for multiple spokes)

## Usage

```hcl
module "hub_spoke" {
  source = "../hub-spoke"

  hub_project_id    = "foundation-network"
  region            = "us-central1"
  domain            = "prod"
  connectivity_type = "peering"

  spokes = {
    dev = {
      project_id  = "foundation-development"
      env_name    = "dev"
      spoke_cidr  = "10.16.0.0/16"
      subnet_cidr = "10.16.0.0/24"
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
| hub_project_id | Project where hub VPC, NCC hub, router, and firewall are created | string | n/a | yes |
| region | Default region for hub and spoke resources | string | n/a | yes |
| domain | Logical domain / env name for naming shared resources | string | n/a | yes |
| spokes | Map of spoke VPCs to create | map(object) | n/a | yes |
| hub_cidr | CIDR reserved for the hub | string | 10.0.0.0/20 | no |
| hub_subnet_cidr | CIDR for the hub subnet | string | 10.0.0.0/24 | no |
| hub_vpc_name | Hub VPC name | string | vpc-hub | no |
| hub_subnet_name | Hub subnet name | string | sb-hub | no |
| hub_router_name | Hub Cloud Router name | string | cr-hub | no |
| hub_router_asn | Hub Cloud Router BGP ASN | number | 64514 | no |
| connectivity_type | ncc or peering | string | peering | no |
| firewall_rules | Map of firewall rules on the hub VPC | map(object) | {} | no |
| labels | Labels applied to NCC resources | map(string) | {} | no |

### `spokes` object structure

| Field | Type | Description |
|-------|------|-------------|
| project_id | string | Spoke project ID |
| region | string | Spoke region (defaults to top-level region) |
| env_name | string | Environment name used for peering naming |
| spoke_cidr | string | Spoke network CIDR |
| subnet_cidr | string | Spoke subnet CIDR |
| vpc_name | string | Spoke VPC name (default vpc-spoke) |
| subnet_name | string | Spoke subnet name (default sb-spoke) |
| workload_type | string | vm / gke / mixed (default vm) |
| pod_cidr | string | GKE pod secondary CIDR (for gke/mixed) |
| svc_cidr | string | GKE services secondary CIDR (for gke/mixed) |
| peering_export_custom_routes | bool | Peering custom route export (default false) |
| peering_import_custom_routes | bool | Peering custom route import (default false) |
| firewall_rules | map(object) | Firewall rules for this spoke VPC (default {}) |

## Outputs

| Name | Description |
|------|-------------|
| hub_vpc_self_link | Self-link of the hub VPC |
| hub_vpc_id | ID of the hub VPC |
| hub_subnet_self_link | Self-link of the hub subnet |
| hub_router_self_link | Self-link of the hub Cloud Router |
| hub_router_asn | BGP ASN of the hub Cloud Router |
| spoke_vpc_self_links | Map of spoke name to VPC self-link |
| spoke_vpc_ids | Map of spoke name to VPC ID |
| spoke_subnet_self_links | Map of spoke name to subnet self-link |
| ncc_hub_id | NCC hub ID (empty when peering) |
| ncc_spoke_ids | Map of spoke name to NCC spoke ID (empty when peering) |
| peering_names | Map of spoke name to peering names (empty when ncc) |
| firewall_rule_ids | Map of firewall rule key to ID on the hub VPC |
| firewall_rule_names | Map of firewall rule key to name on the hub VPC |
| spoke_firewall_rule_ids | Map of spoke name to map of firewall rule key to ID |
| spoke_firewall_rule_names | Map of spoke name to map of firewall rule key to name |