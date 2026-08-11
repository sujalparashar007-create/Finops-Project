# ==============================================================================
# EXAMPLE: custom-iam-roles module — basic outputs
# ==============================================================================

output "custom_role_ids" {
  description = "Map of role_id -> fully-qualified custom role ID"
  value       = module.custom_roles.custom_role_ids
}
