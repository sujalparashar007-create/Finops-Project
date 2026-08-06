# ==============================================================================
# MODULE: secret-manager — outputs
# ==============================================================================

output "secret_ids" {
  description = "Map of secret key to secret_id (short name) — use these to wire into Cloud Function secret_environment_variables or other consumers"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.secret_id }
}

output "secret_names" {
  description = "Map of secret key to full resource name (projects/PROJECT/secrets/SECRET_ID)"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.name }
}
