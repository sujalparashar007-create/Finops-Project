module "firewall" {
  source = "../../"

  project_id    = "my-project"
  vpc_self_link = "projects/my-project/global/networks/my-vpc"

  rules = {
    allow_ssh = {
      name          = "allow-ssh"
      description   = "Allow SSH from anywhere"
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
