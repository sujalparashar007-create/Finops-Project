# ==============================================================================
# MODULE: iam-deny-policy — IAM Deny Policy
# ==============================================================================
# The only real exception mechanism — IAM Allow policies are purely additive
# and cannot subtract a higher-level grant. google_iam_deny_policy expresses
# "this principal/role is explicitly blocked here."
# ==============================================================================

resource "google_iam_deny_policy" "this" {
  parent       = urlencode("cloudresourcemanager.googleapis.com/${var.scope}/${var.target_id}")
  name         = "deny-${var.policy_name}"
  display_name = "Deny policy: ${var.policy_name} (${var.target_id})"

  dynamic "rules" {
    for_each = var.deny_rules
    content {
      description = rules.value.reason
      deny_rule {
        denied_principals     = rules.value.denied_principals
        denied_permissions    = rules.value.denied_permissions
        exception_principals  = rules.value.exception_principals
        exception_permissions = rules.value.exception_permissions

        dynamic "denial_condition" {
          for_each = rules.value.denial_condition != null ? [rules.value.denial_condition] : []
          content {
            title       = denial_condition.value.title
            expression  = denial_condition.value.expression
            description = denial_condition.value.description
            location    = denial_condition.value.location
          }
        }
      }
    }
  }
}
