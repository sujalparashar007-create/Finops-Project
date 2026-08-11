resource "google_compute_network" "spoke" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "primary" {
  project                  = var.project_id
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.spoke.self_link
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.workload_type != "vm" ? [1] : []
    content {
      range_name    = "gke-pods"
      ip_cidr_range = var.pod_cidr
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.workload_type != "vm" ? [1] : []
    content {
      range_name    = "gke-services"
      ip_cidr_range = var.svc_cidr
    }
  }
}

