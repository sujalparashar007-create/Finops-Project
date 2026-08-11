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

output "org_iam_binding_ids" {
  description = "Map of org IAM binding key to resource ID (null when scope != organization)"
  value       = local.is_hierarchical ? { for k, v in google_organization_iam_member.org_bindings : k => v.id } : null
}
