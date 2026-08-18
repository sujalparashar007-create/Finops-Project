resource "google_compute_network_peering" "hub_to_spoke" {
  name         = "hub-to-${var.env_name}"
  network      = var.hub_vpc_self_link
  peer_network = var.spoke_vpc_self_link

  export_custom_routes = var.export_custom_routes
  import_custom_routes = var.import_custom_routes
}

resource "google_compute_network_peering" "spoke_to_hub" {
  name         = "spoke-${var.env_name}-to-hub"
  network      = var.spoke_vpc_self_link
  peer_network = var.hub_vpc_self_link

  export_custom_routes = var.export_custom_routes
  import_custom_routes = var.import_custom_routes
}
