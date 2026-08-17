# ==============================================================================
# Stage 4: Networks Hub-and-Spoke
# ==============================================================================
# Deploys hub VPC, dev spoke VPC, VPC peering, and firewall rules.
# Follows hub-spoke.md Task 4 instructions.
# ==============================================================================

# ------------------------------------------------------------------------------
# HUB
# ------------------------------------------------------------------------------
module "hub" {
  source = "../../hub"

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
# SPOKES (dev only for single-VM validation)
# ------------------------------------------------------------------------------
module "spoke" {
  source   = "../../spoke"
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
# PEERING (classic VPC peering — Finding 1 decision)
# ------------------------------------------------------------------------------
module "peering" {
  source   = "../../peering"
  for_each = var.spokes

  hub_vpc_self_link   = module.hub.vpc_self_link
  spoke_vpc_self_link = module.spoke[each.key].vpc_self_link
  env_name            = each.value.env_name

  export_custom_routes = each.value.peering_export_custom_routes
  import_custom_routes = each.value.peering_import_custom_routes
}

# ------------------------------------------------------------------------------
# FIREWALL (per-VPC — Finding 4: hub + each spoke)
# ------------------------------------------------------------------------------
module "firewall_hub" {
  source = "../../firewall"

  project_id    = var.hub_project_id
  vpc_self_link = module.hub.vpc_self_link
  rules         = var.firewall_rules
}

module "firewall_spoke" {
  source   = "../../firewall"
  for_each = var.spokes

  project_id    = each.value.project_id
  vpc_self_link = module.spoke[each.key].vpc_self_link
  rules         = each.value.firewall_rules
}
