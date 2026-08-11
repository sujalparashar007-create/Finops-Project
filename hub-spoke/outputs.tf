# ==============================================================================
# MODULE: hub-spoke - outputs
# ==============================================================================

# --- HUB ---

output "hub_vpc_self_link" {
  description = "Self-link of the hub VPC"
  value       = module.hub.vpc_self_link
}

output "hub_vpc_id" {
  description = "ID of the hub VPC"
  value       = module.hub.vpc_id
}

output "hub_subnet_self_link" {
  description = "Self-link of the hub subnet"
  value       = module.hub.subnet_self_link
}

output "hub_router_self_link" {
  description = "Self-link of the hub Cloud Router"
  value       = module.hub.router_self_link
}

output "hub_router_asn" {
  description = "BGP ASN of the hub Cloud Router"
  value       = module.hub.router_asn
}

# --- SPOKES ---

output "spoke_vpc_self_links" {
  description = "Map of spoke name to spoke VPC self-link"
  value       = { for k, v in module.spokes : k => v.vpc_self_link }
}

output "spoke_vpc_ids" {
  description = "Map of spoke name to spoke VPC ID"
  value       = { for k, v in module.spokes : k => v.vpc_id }
}

output "spoke_subnet_self_links" {
  description = "Map of spoke name to spoke primary subnet self-link"
  value       = { for k, v in module.spokes : k => v.subnet_self_link }
}

# --- CONNECTIVITY ---

output "ncc_hub_id" {
  description = "NCC hub resource ID (empty set when peering is used)"
  value       = var.connectivity_type == "ncc" ? [module.connectivity_ncc[0].hub_id] : []
}

output "ncc_spoke_ids" {
  description = "Map of spoke name to NCC spoke resource ID (empty when peering is used)"
  value       = var.connectivity_type == "ncc" ? module.connectivity_ncc[0].spoke_ids : {}
}

output "peering_names" {
  description = "Map of spoke name to bidirectional peering names (empty when ncc is used)"
  value       = var.connectivity_type == "peering" ? { for k, v in module.connectivity_peering : k => [v.hub_peering_name, v.spoke_peering_name] } : {}
}

# --- FIREWALL ---

output "firewall_rule_ids" {
  description = "Map of firewall rule key to firewall rule ID"
  value       = module.firewall.rule_ids
}

output "firewall_rule_names" {
  description = "Map of firewall rule key to firewall rule name"
  value       = module.firewall.rule_names
}