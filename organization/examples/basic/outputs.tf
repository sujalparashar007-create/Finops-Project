# ==============================================================================
# EXAMPLE: organization module — basic outputs
# ==============================================================================

output "org_id" {
  description = "Organization ID"
  value       = module.org.org_id
}

output "org_name" {
  description = "Organization display name"
  value       = module.org.org_name
}
