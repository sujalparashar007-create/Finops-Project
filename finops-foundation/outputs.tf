# ==============================================================================
# MODULE: finops-foundation — outputs
# ==============================================================================

output "project_id" {
  description = "GCP project ID (passthrough for downstream modules)"
  value       = var.project_id
}
