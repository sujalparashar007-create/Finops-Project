# ==============================================================================
# STAGE 02: Hub-and-Spoke networking
# ==============================================================================
# Consumes the host projects from 01 (project IDs + tf-executor SAs) and calls
# the hub-spoke orchestrator module, which builds: hub VPC/subnet/router,
# spoke VPCs/subnets, peering or NCC connectivity, and hub firewall rules.
# ==============================================================================

data "terraform_remote_state" "host_projects" {
  backend = "gcs"
  config = {
    bucket = "finops-foundation-tfstate"
    prefix = "01-folders-host-projects"
  }
}

locals {
  terraform_sa_email = data.terraform_remote_state.host_projects.outputs.terraform_sa_emails[var.hub_project_key]
  hub_project_id     = data.terraform_remote_state.host_projects.outputs.project_ids[var.hub_project_key]

  # Resolve each spoke's project ID from the host-projects stage by logical key.
  hub_spokes = {
    for k, v in var.spokes : k => {
      project_id                   = data.terraform_remote_state.host_projects.outputs.project_ids[v.host_project_key]
      region                       = v.region
      env_name                     = coalesce(v.env_name, k)
      spoke_cidr                   = v.spoke_cidr
      subnet_cidr                  = v.subnet_cidr
      vpc_name                     = v.vpc_name
      subnet_name                  = v.subnet_name
      workload_type                = v.workload_type
      pod_cidr                     = v.pod_cidr
      svc_cidr                     = v.svc_cidr
      peering_export_custom_routes = v.peering_export_custom_routes
      peering_import_custom_routes = v.peering_import_custom_routes
    }
  }
}

module "hub_spoke" {
  source = "../../hub-spoke"

  hub_project_id    = local.hub_project_id
  region            = var.region
  domain            = var.domain
  connectivity_type = var.connectivity_type

  hub_cidr        = var.hub_cidr
  hub_subnet_cidr = var.hub_subnet_cidr
  hub_vpc_name    = var.hub_vpc_name
  hub_subnet_name = var.hub_subnet_name
  hub_router_name = var.hub_router_name
  hub_router_asn  = var.hub_router_asn

  spokes = local.hub_spokes

  firewall_rules = var.firewall_rules
  labels         = var.labels
}
