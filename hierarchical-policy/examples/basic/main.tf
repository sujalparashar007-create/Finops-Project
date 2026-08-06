# Example: finops-policy basic usage
# Shows both org-scope and folder-scope policy calls.
# Run: terraform init && terraform validate

# --- Organization-scoped policy ---
module "org_policy" {
  source = "../../"

  scope  = "organization"
  org_id = "123456789"

  rules = {
    corp_ssh = {
      priority    = 200
      action      = "allow"
      src_ranges  = ["198.51.100.0/24"]
      ports       = ["22"]
      description = "Allow enterprise SSH from corporate range"
    }
    vpn_ssh = {
      priority    = 300
      action      = "allow"
      src_ranges  = ["198.51.101.0/24"]
      ports       = ["22"]
      description = "Allow enterprise SSH from VPN range"
    }
  }
}

# --- Folder-scoped policy ---
module "folder_policy" {
  source = "../../"

  scope     = "folder"
  folder_id = "987654321"

  rules = {
    deny_public_rdp = {
      priority    = 100
      action      = "deny"
      src_ranges  = ["0.0.0.0/0"]
      ports       = ["3389"]
      description = "Deny public RDP"
    }
  }
}

# --- Project-scoped policy (VPC firewall rules) ---
module "project_policy" {
  source = "../../"

  scope      = "project"
  project_id = "my-project-id"
  network    = "my-vpc"

  rules = {
    allow_bastion_ssh = {
      priority    = 100
      action      = "allow"
      src_ranges  = ["10.10.10.0/24"]
      ports       = ["22"]
      description = "Allow SSH from bastion subnet"
    }
  }
}
