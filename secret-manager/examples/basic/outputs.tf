output "secret_ids" {
  description = "Map of secret key to secret_id"
  value       = module.secrets.secret_ids
}

output "secret_names" {
  description = "Map of secret key to full resource name"
  value       = module.secrets.secret_names
}
