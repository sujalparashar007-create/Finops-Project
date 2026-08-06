# ==============================================================================
# MODULE: finops-org-policy — outputs
# ==============================================================================

output "policy_id" {
  description = "Full resource ID of the hierarchical firewall policy"
  value       = local.is_hierarchical ? google_compute_firewall_policy.finops[0].id : null
}

output "policy_name" {
  description = "Short name of the hierarchical firewall policy"
  value       = local.is_hierarchical ? google_compute_firewall_policy.finops[0].short_name : null
}
