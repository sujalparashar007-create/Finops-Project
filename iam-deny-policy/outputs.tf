# ==============================================================================
# MODULE: iam-deny-policy — outputs
# ==============================================================================

output "name" {
  description = "Full resource name of the deny policy"
  value       = google_iam_deny_policy.this.name
}

output "parent" {
  description = "Parent scope/target the policy is attached to"
  value       = google_iam_deny_policy.this.parent
}
