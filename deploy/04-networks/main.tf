# ==============================================================================
# Stage 4: Networks Hub-and-Spoke + Shared VPC + Validation VMs
# ==============================================================================
# Deploys hub VPC, spoke VPCs, connectivity (peering or NCC), firewall
# rules, Shared VPC host/service project attachment, and two validation VMs
# for bidirectional peering testing.
#
# All resources are controlled from this single root module.
# ==============================================================================

# ------------------------------------------------------------------------------
# API ENABLEMENT
# ------------------------------------------------------------------------------
resource "google_project_service" "hub_apis" {
  for_each = toset(var.hub_activate_apis)
  project  = var.hub_project_id
  service  = each.value
}

resource "google_project_service" "spoke_apis" {
  for_each = toset(var.spoke_activate_apis)
  project  = var.spokes[var.validation_spoke].project_id
  service  = each.value
}

resource "google_project_service" "service_project_apis" {
  for_each = var.create_service_project ? toset(var.service_project_activate_apis) : []
  project  = var.service_project_id
  service  = each.value
}

# ------------------------------------------------------------------------------
# SERVICE PROJECT
# ------------------------------------------------------------------------------
resource "google_project" "service_project" {
  count           = var.create_service_project ? 1 : 0
  name            = var.service_project_id
  project_id      = var.service_project_id
  org_id          = var.folder_id == "" ? var.org_id : null
  folder_id       = var.folder_id != "" ? var.folder_id : null
  billing_account = var.billing_account
}

# ------------------------------------------------------------------------------
# SHARED VPC
# ------------------------------------------------------------------------------
resource "google_compute_shared_vpc_host_project" "spoke_host" {
  project = var.spokes[var.validation_spoke].project_id
}

resource "google_compute_shared_vpc_service_project" "spoke_service" {
  count           = var.create_service_project ? 1 : 0
  host_project    = google_compute_shared_vpc_host_project.spoke_host.project
  service_project = var.service_project_id
}

locals {
  service_project_number = var.create_service_project ? google_project.service_project[0].number : var.service_project_number
}

resource "google_project_iam_member" "service_project_network_user" {
  depends_on = [google_project_service.service_project_apis]
  for_each = {
    cloudservices = "serviceAccount:${local.service_project_number}@cloudservices.gserviceaccount.com"
    compute       = "serviceAccount:${local.service_project_number}-compute@developer.gserviceaccount.com"
  }
  project = var.spokes[var.validation_spoke].project_id
  role    = "roles/compute.networkUser"
  member  = each.value
}

# ------------------------------------------------------------------------------
# HUB-AND-SPOKE NETWORKING
# ------------------------------------------------------------------------------
module "hub_spoke" {
  source = "../../hub-spoke"

  hub_project_id    = var.hub_project_id
  region            = var.region
  domain            = var.domain
  connectivity_type = var.connectivity_type

  hub_cidr        = var.hub_cidr
  hub_subnet_cidr = var.hub_subnet_cidr
  hub_vpc_name    = var.hub_vpc_name
  hub_subnet_name = var.hub_subnet_name
  hub_router_name = var.hub_router_name
  hub_router_asn  = var.hub_router_asn

  spokes = var.spokes

  firewall_rules = var.firewall_rules

  labels = var.labels

  depends_on = [
    google_project_service.hub_apis,
    google_project_service.spoke_apis,
    google_compute_shared_vpc_host_project.spoke_host,
  ]
}

# ------------------------------------------------------------------------------
# VALIDATION VM — HUB SIDE (in hub project, hub subnet)
# ------------------------------------------------------------------------------
resource "google_compute_instance" "validation_hub" {
  count = var.create_validation_vms ? 1 : 0

  project      = var.hub_project_id
  name         = var.hub_validation_vm_name
  machine_type = var.hub_validation_vm_machine_type
  zone         = var.hub_validation_vm_zone

  boot_disk {
    initialize_params {
      image = var.validation_vm_image
      size  = var.validation_vm_disk_size
      type  = var.validation_vm_disk_type
    }
  }

  network_interface {
    network    = module.hub_spoke.hub_vpc_self_link
    subnetwork = module.hub_spoke.hub_subnet_self_link
    # No external IP — access via IAP tunnel only
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  depends_on = [module.hub_spoke]
}

# ------------------------------------------------------------------------------
# VALIDATION VM — SPOKE SIDE (in service project, spoke subnet via Shared VPC)
# ------------------------------------------------------------------------------
resource "google_compute_instance" "validation_spoke" {
  count = var.create_validation_vms ? 1 : 0

  project      = var.service_project_id
  name         = var.spoke_validation_vm_name
  machine_type = var.spoke_validation_vm_machine_type
  zone         = var.spoke_validation_vm_zone

  boot_disk {
    initialize_params {
      image = var.validation_vm_image
      size  = var.validation_vm_disk_size
      type  = var.validation_vm_disk_type
    }
  }

  network_interface {
    network    = module.hub_spoke.spoke_vpc_self_links[var.validation_spoke]
    subnetwork = module.hub_spoke.spoke_subnet_self_links[var.validation_spoke]
    # No external IP — access via IAP tunnel only
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  depends_on = [
    module.hub_spoke,
    google_compute_shared_vpc_service_project.spoke_service,
    google_project_iam_member.service_project_network_user,
  ]
}
