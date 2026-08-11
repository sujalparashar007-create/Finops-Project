module "peering" {
  source = "../../"

  hub_vpc_self_link   = "projects/foundation-network/global/networks/hub-vpc"
  spoke_vpc_self_link = "projects/foundation-development/global/networks/spoke-vpc"
  env_name            = "dev"

  export_custom_routes = false
  import_custom_routes = false
}
