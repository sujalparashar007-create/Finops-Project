module "hub_spoke" {
  source = "../../"

  hub_project_id    = "foundation-network"
  region            = "us-central1"
  domain            = "prod"
  connectivity_type = "peering"

  spokes = {
    dev = {
      project_id  = "foundation-development"
      env_name    = "dev"
      spoke_cidr  = "10.16.0.0/16"
      subnet_cidr = "10.16.0.0/24"
    }
    staging = {
      project_id  = "foundation-staging"
      env_name    = "staging"
      spoke_cidr  = "10.32.0.0/16"
      subnet_cidr = "10.32.0.0/24"
    }
  }

  firewall_rules = {
    allow_ssh = {
      name          = "allow-ssh"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  }
}