# ==============================================================================
# MODULE: iam — outputs
# ==============================================================================
# No semantic outputs — IAM resources are self-managing. Caller references
# the input resource_id to confirm what was targeted.

output "scope" {
  description = "Echoes the scope this module instance was configured for."
  value       = var.scope
}

output "resource_id" {
  description = "Echoes the resource_id this module instance was configured for."
  value       = var.resource_id
}
