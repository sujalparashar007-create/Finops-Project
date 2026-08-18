module "peering" {
  source = "../../"

  hub_vpc_self_link   = "projects/example-hub-project/global/networks/hub-vpc"
  spoke_vpc_self_link = "projects/example-spoke-project/global/networks/spoke-vpc"
  env_name            = "dev"

  export_custom_routes = false
  import_custom_routes = false
}
