# ==============================================================================
# MODULE: service-projects - Service Project Factory
# ==============================================================================
# Creates one service project for EACH host project (no folders - service
# projects belong to the requesting org). Each service project gets a VM that
# attaches to its host project's Shared VPC subnet.
#
# Input: var.hosts is a map keyed by host project ID. Each entry defines the
# service project + VM that belongs to that host.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CREATE ONE SERVICE PROJECT PER HOST
# ------------------------------------------------------------------------------
module "projects" {
  source = "../project"

  for_each = var.hosts

  project_id         = each.value.service_project_id
  project_name       = each.value.service_project_name
  billing_account_id = var.billing_account_id
  org_id             = var.org_id
  folder_id          = ""
  terraform_user     = var.terraform_user
  terraform_sa_roles = var.service_project_sa_roles
}

# ------------------------------------------------------------------------------
# 2. ENABLE COMPUTE API ON EACH SERVICE PROJECT
# ------------------------------------------------------------------------------
resource "google_project_service" "compute_api" {
  for_each = var.hosts

  project            = each.value.service_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false

  depends_on = [module.projects]
}

# ------------------------------------------------------------------------------
# 3. ATTACH EACH SERVICE PROJECT TO ITS HOST PROJECT'S SHARED VPC
# ------------------------------------------------------------------------------
resource "google_compute_shared_vpc_service_project" "service" {
  for_each = var.hosts

  host_project_id = each.key
  service_project = module.projects[each.key].project_id

  depends_on = [google_project_service.compute_api]
}

# ------------------------------------------------------------------------------
# 4. PROVISION A VM IN EACH SERVICE PROJECT ATTACHED TO ITS HOST'S SHARED VPC
# ------------------------------------------------------------------------------
resource "google_compute_instance" "vm" {
  for_each = var.hosts

  project      = module.projects[each.key].project_id
  name         = each.value.vm.name
  machine_type = each.value.vm.machine_type
  zone         = each.value.vm.zone

  metadata = each.value.vm.metadata
  tags     = each.value.vm.tags

  boot_disk {
    initialize_params {
      image = each.value.vm.boot_image
    }
  }

  network_interface {
    # Attach to this host project's shared VPC subnet
    subnetwork         = each.value.vm.subnetwork_self_link
    subnetwork_project = each.key
  }

  dynamic "access_config" {
    for_each = each.value.vm.external_ip ? [1] : []
    content {}
  }

  depends_on = [google_compute_shared_vpc_service_project.service]
}
