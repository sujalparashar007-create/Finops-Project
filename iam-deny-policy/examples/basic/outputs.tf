# ==============================================================================
# EXAMPLE: iam-deny-policy module — basic outputs
# ==============================================================================

output "policy_name" {
  description = "Full resource name of the deny policy"
  value       = module.deny_public_access.name
}

output "parent" {
  description = "Parent scope/target"
  value       = module.deny_public_access.parent
}
