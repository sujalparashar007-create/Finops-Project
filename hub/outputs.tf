output "vpc_self_link" {
  description = "Self-link of the hub VPC"
  value       = google_compute_network.hub.self_link
}

output "vpc_id" {
  description = "ID of the hub VPC"
  value       = google_compute_network.hub.id
}

output "vpc_name" {
  description = "Name of the hub VPC"
  value       = google_compute_network.hub.name
}

output "subnet_self_link" {
  description = "Self-link of the hub subnet"
  value       = google_compute_subnetwork.hub.self_link
}

output "subnet_name" {
  description = "Name of the hub subnet"
  value       = google_compute_subnetwork.hub.name
}

output "subnet_cidr" {
  description = "CIDR range of the hub subnet"
  value       = google_compute_subnetwork.hub.ip_cidr_range
}

output "router_self_link" {
  description = "Self-link of the Cloud Router"
  value       = google_compute_router.hub.self_link
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.hub.name
}

output "router_asn" {
  description = "BGP ASN of the Cloud Router"
  value       = google_compute_router.hub.bgp.0.asn
}

output "region" {
  description = "Region where hub resources are deployed"
  value       = var.region
}


