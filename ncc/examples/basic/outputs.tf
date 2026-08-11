output "hub_id" {
  description = "ID of the NCC hub"
  value       = module.ncc.hub_id
}

output "hub_name" {
  description = "Name of the NCC hub"
  value       = module.ncc.hub_name
}

output "hub_state" {
  description = "Current state of the NCC hub"
  value       = module.ncc.hub_state
}

output "spoke_ids" {
  description = "Map of spoke name to NCC spoke resource ID"
  value       = module.ncc.spoke_ids
}

output "spoke_names" {
  description = "Map of spoke name to NCC spoke resource name"
  value       = module.ncc.spoke_names
}
