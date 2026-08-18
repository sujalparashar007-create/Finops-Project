output "hub_vpc_self_link" {
  description = "Self-link of the hub VPC"
  value       = module.hub_spoke.hub_vpc_self_link
}

output "hub_vpc_id" {
  description = "ID of the hub VPC"
  value       = module.hub_spoke.hub_vpc_id
}

output "hub_subnet_self_link" {
  description = "Self-link of the hub subnet"
  value       = module.hub_spoke.hub_subnet_self_link
}

output "hub_router_self_link" {
  description = "Self-link of the hub Cloud Router"
  value       = module.hub_spoke.hub_router_self_link
}

output "spoke_vpc_self_links" {
  description = "Map of spoke name to VPC self-link"
  value       = module.hub_spoke.spoke_vpc_self_links
}

output "spoke_subnet_self_links" {
  description = "Map of spoke name to subnet self-link"
  value       = module.hub_spoke.spoke_subnet_self_links
}

output "peering_names" {
  description = "Map of spoke name to peering names (empty when ncc is used)"
  value       = module.hub_spoke.peering_names
}

output "ncc_hub_id" {
  description = "NCC hub resource ID (empty when peering is used)"
  value       = module.hub_spoke.ncc_hub_id
}

output "ncc_spoke_ids" {
  description = "Map of spoke name to NCC spoke resource ID (empty when peering is used)"
  value       = module.hub_spoke.ncc_spoke_ids
}

output "firewall_rule_ids" {
  description = "Map of firewall rule key to firewall rule ID on the hub VPC"
  value       = module.hub_spoke.firewall_rule_ids
}

output "spoke_firewall_rule_ids" {
  description = "Map of spoke name to map of firewall rule key to rule ID"
  value       = module.hub_spoke.spoke_firewall_rule_ids
}

output "service_project_id" {
  description = "Service project ID attached to the spoke Shared VPC"
  value       = var.service_project_id
}

output "validation_hub_vm_self_link" {
  description = "Self-link of the hub validation VM"
  value       = var.create_validation_vms ? google_compute_instance.validation_hub[0].self_link : ""
}

output "validation_hub_vm_internal_ip" {
  description = "Internal IP of the hub validation VM"
  value       = var.create_validation_vms ? google_compute_instance.validation_hub[0].network_interface[0].network_ip : ""
}

output "validation_spoke_vm_self_link" {
  description = "Self-link of the spoke validation VM (in service project)"
  value       = var.create_validation_vms ? google_compute_instance.validation_spoke[0].self_link : ""
}

output "validation_spoke_vm_internal_ip" {
  description = "Internal IP of the spoke validation VM (in service project)"
  value       = var.create_validation_vms ? google_compute_instance.validation_spoke[0].network_interface[0].network_ip : ""
}
