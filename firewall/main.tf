resource "google_compute_firewall" "rules" {
  for_each    = var.rules
  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  network     = var.vpc_self_link
  direction   = each.value.direction
  priority    = each.value.priority

  source_ranges           = each.value.direction == "INGRESS" ? each.value.source_ranges : null
  destination_ranges      = each.value.direction == "EGRESS" ? each.value.destination_ranges : null
  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  source_service_accounts = length(each.value.source_service_accounts) > 0 ? each.value.source_service_accounts : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}