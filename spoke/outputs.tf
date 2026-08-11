output "vpc_self_link" {
  description = "Self-link of the spoke VPC"
  value       = google_compute_network.spoke.self_link
}

output "vpc_id" {
  description = "ID of the spoke VPC"
  value       = google_compute_network.spoke.id
}

output "vpc_name" {
  description = "Name of the spoke VPC"
  value       = google_compute_network.spoke.name
}

output "subnet_self_link" {
  description = "Self-link of the primary subnet"
  value       = google_compute_subnetwork.primary.self_link
}

output "subnet_name" {
  description = "Name of the primary subnet"
  value       = google_compute_subnetwork.primary.name
}

output "subnet_cidr" {
  description = "CIDR of the primary subnet"
  value       = google_compute_subnetwork.primary.ip_cidr_range
}

output "pod_range_name" {
  description = "GKE pod secondary range name (empty for vm)"
  value       = var.workload_type != "vm" ? "gke-pods" : ""
}

output "svc_range_name" {
  description = "GKE services secondary range name (empty for vm)"
  value       = var.workload_type != "vm" ? "gke-services" : ""
}

