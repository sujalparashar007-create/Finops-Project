output "hub_peering_name" {
  description = "Name of the hub-to-spoke peering"
  value       = google_compute_network_peering.hub_to_spoke.name
}

output "spoke_peering_name" {
  description = "Name of the spoke-to-hub peering"
  value       = google_compute_network_peering.spoke_to_hub.name
}
