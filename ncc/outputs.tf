output "hub_id" {
  description = "NCC hub resource ID"
  value       = google_network_connectivity_hub.hub.id
}

output "hub_name" {
  description = "NCC hub resource name"
  value       = google_network_connectivity_hub.hub.name
}

output "hub_state" {
  description = "Current state of the NCC hub"
  value       = google_network_connectivity_hub.hub.state
}

output "spoke_ids" {
  description = "Map of spoke name to NCC spoke resource ID"
  value       = { for k, v in google_network_connectivity_spoke.spokes : k => v.id }
}

output "spoke_names" {
  description = "Map of spoke name to NCC spoke resource name"
  value       = { for k, v in google_network_connectivity_spoke.spokes : k => v.name }
}
