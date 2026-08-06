# ==============================================================================
# MODULE: finops-policy — Hierarchical + VPC Firewall Policy
# ==============================================================================
# Creates firewall policies at the chosen scope:
#
#   "organization" → org-level hierarchical policy (inherited by all projects)
#   "folder"       → folder-level hierarchical policy (inherited by descendants)
#   "project"      → VPC firewall rules on a specific network
#
# Rules are declarative via var.rules — same structure across all scopes.
#
# Usage (org):
#   module "finops_policy" { source = "../finops-policy"; scope = "organization"; org_id = "123"; rules = {...} }
#
# Usage (folder):
#   module "finops_policy" { source = "../finops-policy"; scope = "folder"; folder_id = "456"; rules = {...} }
#
# Usage (project):
#   module "finops_policy" { source = "../finops-policy"; scope = "project"; project_id = "my-proj"; network = "my-vpc"; rules = {...} }
# ==============================================================================

locals {
  is_hierarchical = var.scope != "project"
  scope_short     = var.scope == "organization" ? "org" : var.scope == "folder" ? "fldr" : "prj"

  # hierarchical policy parent (org or folder only)
  parent = var.scope == "organization" ? "organizations/${var.org_id}" : "folders/${var.folder_id}"
}

# ==============================================================================
# HIERARCHICAL POLICY (org | folder scope)
# ==============================================================================

resource "google_compute_firewall_policy" "finops" {
  count = local.is_hierarchical ? 1 : 0

  short_name  = "fp-finops-${local.scope_short}-${var.policy_suffix}"
  parent      = local.parent
  description = "FinOps hierarchical firewall policy — scope: ${var.scope}"
}

resource "google_compute_firewall_policy_rule" "rules" {
  for_each = local.is_hierarchical ? var.rules : {}

  firewall_policy = google_compute_firewall_policy.finops[0].id
  priority        = each.value.priority
  direction       = each.value.direction
  action          = each.value.action
  enable_logging  = each.value.enable_logging

  match {
    src_ip_ranges = each.value.src_ranges
    layer4_configs {
      ip_protocol = "tcp"
      ports       = each.value.ports
    }
  }

  description = each.value.description
}

resource "google_compute_firewall_policy_association" "scope" {
  count = local.is_hierarchical ? 1 : 0

  name              = "fp-finops-${local.scope_short}-${var.policy_suffix}-association"
  attachment_target = local.parent
  firewall_policy   = google_compute_firewall_policy.finops[0].id
}

# ==============================================================================
# VPC FIREWALL RULES (project scope)
# ==============================================================================

resource "google_compute_firewall" "vpc_rules" {
  for_each = local.is_hierarchical ? {} : var.rules

  project  = var.project_id
  network  = var.network
  name     = "fw-finops-${replace(each.key, "_", "-")}"
  priority = each.value.priority

  source_ranges = each.value.src_ranges

  dynamic "allow" {
    for_each = each.value.action == "allow" ? [1] : []
    content {
      protocol = "tcp"
      ports    = each.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "deny" ? [1] : []
    content {
      protocol = "tcp"
      ports    = each.value.ports
    }
  }

  description = each.value.description
}
