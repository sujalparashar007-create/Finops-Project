# ==============================================================================
# EXAMPLE: projects module — YAML-driven usage
# ==============================================================================
# Run: cd examples/yaml-driven && terraform init && terraform plan
# ==============================================================================
# This example demonstrates defining projects via a YAML configuration file
# instead of inline Terraform blocks. Edit projects.yaml to manage your projects
# — no Terraform code changes needed.
# ==============================================================================

locals {
  factory_projects = yamldecode(file("${path.module}/projects.yaml")).projects
}

module "projects" {
  source = "../../"

  billing_account_id = var.billing_account_id

  projects = {
    for pid, p in local.factory_projects : pid => {
      folder_id     = try(p.folder_id, "")
      activate_apis = try(p.activate_apis, [])
      labels        = p.labels
    }
  }
}