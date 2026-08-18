module "hub" {
  source = "../../"

  project_id  = "example-hub-project"
  region      = "us-central1"
  hub_cidr    = "10.0.0.0/20"
  subnet_cidr = "10.0.0.0/24"
}


