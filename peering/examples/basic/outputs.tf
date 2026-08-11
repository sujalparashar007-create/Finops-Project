output "hub_peering_name" {
  description = "Name of the hub-to-spoke peering"
  value       = module.peering.hub_peering_name
}

output "spoke_peering_name" {
  description = "Name of the spoke-to-hub peering"
  value       = module.peering.spoke_peering_name
}
