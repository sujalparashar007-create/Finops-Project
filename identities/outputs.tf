# ==============================================================================
# MODULE: identities — outputs
# ==============================================================================

output "emails" {
  description = "Map of account_id -> SA email, for other modules to reference"
  value       = { for k, v in google_service_account.sa : k => v.email }
}

output "names" {
  description = "Map of account_id -> SA fully-qualified resource name"
  value       = { for k, v in google_service_account.sa : k => v.name }
}
