# ==============================================================================
# MODULE: hub-spoke - Main Hub-and-Spoke Orchestration
# ==============================================================================
# The main networking module for the project. Orchestrates:
#   1. Hub VPC + subnet + Cloud Router          (hub module)
#   2. One or more spoke VPCs                   (spoke module)
#   3. Connectivity hub <-> spokes              (ncc or peering module)
#   4. Firewall rules on the hub VPC            (firewall module)
#
# Connectivity is selected via var.connectivity_type:
#   - "ncc"     : Network Connectivity Center (full-mesh, for 2+ spokes)
#   - "peering" : classic VPC Network Peering (per spoke pair)
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: HUB - hub VPC, subnet, and Cloud Router
# ------------------------------------------------------------------------------
module "hub" {
  source = "../hub"

  project_id  = var.hub_project_id
  region      = var.region
  hub_cidr    = var.hub_cidr
  subnet_cidr = var.hub_subnet_cidr
  vpc_name    = var.hub_vpc_name
  subnet_name = var.hub_subnet_name
  router_name = var.hub_router_name
  router_asn  = var.hub_router_asn
}

# ------------------------------------------------------------------------------
# STEP 2: SPOKES - spoke VPCs (one per entry in var.spokes)
# ------------------------------------------------------------------------------
module "spokes" {
  source   = "../spoke"
  for_each = var.spokes

  project_id    = each.value.project_id
  region        = coalesce(each.value.region, var.region)
  env_name      = each.value.env_name
  spoke_cidr    = each.value.spoke_cidr
  subnet_cidr   = each.value.subnet_cidr
  vpc_name      = each.value.vpc_name
  subnet_name   = each.value.subnet_name
  workload_type = each.value.workload_type
  pod_cidr      = each.value.pod_cidr
  svc_cidr      = each.value.svc_cidr
}

# ------------------------------------------------------------------------------
# STEP 3A: NCC CONNECTIVITY (full-mesh across spokes)
# ------------------------------------------------------------------------------
module "connectivity_ncc" {
  source = "../ncc"

  count = var.connectivity_type == "ncc" ? 1 : 0

  hub_project_id = var.hub_project_id
  hub_name       = "ncc-hub-${var.domain}"
  region         = var.region

  vpc_spokes = {
    for k, v in module.spokes : k => {
      project_id    = var.spokes[k].project_id
      vpc_self_link = v.vpc_self_link
    }
  }

  labels = var.labels
}

# ------------------------------------------------------------------------------
# STEP 3B: PEERING CONNECTIVITY (bidirectional pair per spoke)
# ------------------------------------------------------------------------------
module "connectivity_peering" {
  source   = "../peering"
  for_each = var.connectivity_type == "peering" ? var.spokes : {}

  hub_vpc_self_link   = module.hub.vpc_self_link
  spoke_vpc_self_link = module.spokes[each.key].vpc_self_link
  env_name            = each.value.env_name

  export_custom_routes = each.value.peering_export_custom_routes
  import_custom_routes = each.value.peering_import_custom_routes
}

# ------------------------------------------------------------------------------
# STEP 4: FIREWALL - rules applied to the hub VPC
# ------------------------------------------------------------------------------
module "firewall" {
  source = "../firewall"

  project_id    = var.hub_project_id
  vpc_self_link = module.hub.vpc_self_link
  rules         = var.firewall_rules
}
