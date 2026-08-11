# ==============================================================================
# MODULE: project-factory — YAML-Driven Project + IAM Factory
# ==============================================================================
# Reads one YAML file per project from factories/projects/ and creates the
# project plus its project-level IAM grants.
# ==============================================================================

locals {
  project_files = fileset("${path.module}/factories/projects", "*.yaml")
  projects_data = {
    for f in local.project_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/projects/${f}"))
  }
}

module "projects" {
  source = "../projects"

  billing_account_id = var.billing_account_id

  projects = {
    for pid, p in local.projects_data : pid => {
      folder_id     = p.folder_id
      activate_apis = try(p.activate_apis, [])
      labels        = p.labels
    }
  }
}

module "project_iam" {
  source   = "../iam"
  for_each = local.projects_data

  scope                  = "project"
  resource_id            = module.projects.project_ids[each.key]
  iam_bindings_additive  = try(each.value.iam_bindings_additive, {})

  depends_on = [module.projects]
}
