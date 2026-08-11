# ==============================================================================
# MODULE: hub — Hub VPC, Subnet, Cloud Router
# ==============================================================================

resource "google_compute_network" "hub" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "hub" {
  project                  = var.project_id
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.hub.self_link
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "hub" {
  project = var.project_id
  name    = var.router_name
  region  = var.region
  network = google_compute_network.hub.self_link
  bgp {
    asn = var.router_asn
  }
}


