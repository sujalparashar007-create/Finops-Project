# ==============================================================================
# MODULE: organization — outputs
# ==============================================================================

output "org_id" {
  description = "GCP Organization ID"
  value       = data.google_organization.org.organization
}

output "org_name" {
  description = "GCP Organization display name"
  value       = data.google_organization.org.display_name
}

output "directory_customer_id" {
  description = "GCP Organization directory customer ID"
  value       = data.google_organization.org.directory_customer_id
}
