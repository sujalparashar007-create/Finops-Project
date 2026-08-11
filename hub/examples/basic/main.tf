module "hub" {
  source = "../../"

  project_id  = "foundation-network"
  region      = "us-central1"
  hub_cidr    = "10.0.0.0/20"
  subnet_cidr = "10.0.0.0/24"
}


