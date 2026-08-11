# ==============================================================================
# EXAMPLE: identities module — basic outputs
# ==============================================================================

output "emails" {
  description = "Map of account_id -> SA email"
  value       = module.identities.emails
}

output "names" {
  description = "Map of account_id -> SA fully-qualified resource name"
  value       = module.identities.names
}
