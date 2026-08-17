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

output "spoke_vpc_self_links" {
  description = "Map of spoke name to VPC self-link"
  value       = { for k, v in module.spoke : k => v.vpc_self_link }
}

output "spoke_subnet_self_links" {
  description = "Map of spoke name to subnet self-link"
  value       = { for k, v in module.spoke : k => v.subnet_self_link }
}

output "peering_names" {
  description = "Map of spoke name to peering names"
  value       = { for k, v in module.peering : k => { hub = v.hub_peering_name, spoke = v.spoke_peering_name } }
}
