# Temporary infrastructure for testing denied-firewall-hits metric
# This creates minimal resources to generate ONE DENIED VPC Flow Log entry
# All resources will be destroyed after testing

provider "google" {
  project = var.project_id
}

# Create a temporary subnet with VPC Flow Logs enabled
resource "google_compute_subnetwork" "test_subnet" {
  name          = "test-denied-fw-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = "default"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Create a temporary firewall rule that DENIES traffic
resource "google_compute_firewall" "test_deny_rule" {
  name      = "test-deny-icmp-traffic"
  network   = "default"
  direction = "INGRESS"

  deny {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["test-deny-target"]
}

# Create a temporary VM in the test subnet
resource "google_compute_instance" "test_vm" {
  name         = "test-denied-firewall-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  tags = ["test-deny-target"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    network    = "default"
    subnetwork = google_compute_subnetwork.test_subnet.name

    access_config {
      # Ephemeral external IP for testing
    }
  }

  metadata_startup_script = "#!/bin/bash\necho 'VM ready for testing'"
  can_ip_forward         = false
}

# Output the VM details
output "test_vm_external_ip" {
  description = "External IP of test VM"
  value       = google_compute_instance.test_vm.network_interface[0].access_config[0].nat_ip
}

output "test_vm_internal_ip" {
  description = "Internal IP of test VM"
  value       = google_compute_instance.test_vm.network_interface[0].network_ip
}

output "test_subnet_name" {
  description = "Name of test subnet with VPC Flow Logs enabled"
  value       = google_compute_subnetwork.test_subnet.name
}
