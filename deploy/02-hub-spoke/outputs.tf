# ==============================================================================
# STAGE 02: outputs — consumed by 03-service-projects
# ==============================================================================

output "hub_vpc_self_link" {
  description = "Self-link of the hub VPC"
  value       = module.hub_spoke.hub_vpc_self_link
}

output "hub_vpc_id" {
  description = "ID of the hub VPC"
  value       = module.hub_spoke.hub_vpc_id
}

output "hub_subnet_self_link" {
  description = "Self-link of the hub subnet"
  value       = module.hub_spoke.hub_subnet_self_link
}

output "hub_router_self_link" {
  description = "Self-link of the hub Cloud Router"
  value       = module.hub_spoke.hub_router_self_link
}

output "hub_router_asn" {
  description = "BGP ASN of the hub Cloud Router"
  value       = module.hub_spoke.hub_router_asn
}

output "spoke_vpc_self_links" {
  description = "Map of spoke logical name to spoke VPC self-link"
  value       = module.hub_spoke.spoke_vpc_self_links
}

output "spoke_subnet_self_links" {
  description = "Map of spoke logical name to spoke primary subnet self-link"
  value       = module.hub_spoke.spoke_subnet_self_links
}

output "peering_names" {
  description = "Map of spoke name to bidirectional peering names (empty when ncc is used)"
  value       = module.hub_spoke.peering_names
}

output "ncc_hub_id" {
  description = "NCC hub resource ID (empty when peering is used)"
  value       = module.hub_spoke.ncc_hub_id
}

output "ncc_spoke_ids" {
  description = "Map of spoke name to NCC spoke resource ID (empty when peering is used)"
  value       = module.hub_spoke.ncc_spoke_ids
}

output "firewall_rule_names" {
  description = "Map of firewall rule key to firewall rule name"
  value       = module.hub_spoke.firewall_rule_names
}
