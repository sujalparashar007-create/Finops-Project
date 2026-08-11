module "spoke" {
  source = "../../"

  project_id    = "foundation-development"
  region        = "us-central1"
  env_name      = "dev"
  spoke_cidr    = "10.16.0.0/16"
  subnet_cidr   = "10.16.0.0/24"
  workload_type = "vm"
}