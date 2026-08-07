# ==============================================================================
# MODULE: finops-budgets — Billing Budgets + Reporting View (Module 2)
# ==============================================================================

# Enforcement: real GCP billing budgets
resource "google_billing_budget" "budget" {
  for_each = var.budgets

  billing_account = var.billing_account
  display_name    = each.value.display_name

  amount {
    specified_amount {
      currency_code = each.value.currency_code
      units         = each.value.units
    }
  }

  dynamic "threshold_rules" {
    for_each = each.value.threshold_rules
    content {
      threshold_percent = threshold_rules.value.threshold_percent
      spend_basis       = try(threshold_rules.value.spend_basis, "CURRENT_SPEND")
    }
  }

  all_updates_rule {
    pubsub_topic                     = var.pubsub_topic_id != "" ? var.pubsub_topic_id : null
    monitoring_notification_channels = try(coalescelist(each.value.monitoring_notification_channels, values(var.notification_channel_ids)), null)
    disable_default_iam_recipients   = each.value.disable_default_iam_recipients
    enable_project_level_recipients  = each.value.enable_project_level_recipients
  }

  budget_filter {
    projects               = try(each.value.budget_filter.projects, null)
    resource_ancestors     = try(each.value.budget_filter.resource_ancestors, null)
    labels                 = try(each.value.budget_filter.labels, null)
    services               = try(each.value.budget_filter.services, null)
    credit_types_treatment = try(each.value.credit_types_treatment, "INCLUDE_ALL_CREDITS")
    calendar_period        = try(each.value.calendar_period, "MONTH")
  }
}

# IAM — billing budgets viewer for all specified members
resource "google_billing_account_iam_member" "viewer" {
  for_each = toset(var.iam_viewers)

  billing_account_id = var.billing_account
  role               = "roles/billing.viewer"
  member             = each.key
}
