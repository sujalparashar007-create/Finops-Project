# ==============================================================================
# MODULE: iam-deny-policy — IAM Deny Policy
# ==============================================================================
# The only real exception mechanism — IAM Allow policies are purely additive
# and cannot subtract a higher-level grant. google_iam_deny_policy expresses
# "this principal/role is explicitly blocked here."
# ==============================================================================

resource "google_iam_deny_policy" "this" {
  parent       = "${var.scope}/${var.target_id}"
  name         = "deny-${var.policy_name}"
  display_name = "Deny policy: ${var.policy_name} (${var.target_id})"

  rules {
    dynamic "deny_rule" {
      for_each = var.deny_rules
      content {
        denied_principals    = deny_rule.value.denied_principals
        denied_permissions   = deny_rule.value.denied_permissions
        exception_principals = deny_rule.value.exception_principals
      }
    }
  }
}
