# ==============================================================================
# MODULE: identities-factory — YAML-Driven Service Account Factory
# ==============================================================================
# Reads one YAML file per service account from factories/identities/ and
# creates the SA plus its project-scoped role grants.
# ==============================================================================

locals {
  sa_files = fileset("${path.module}/factories/identities", "*.yaml")
  sa_data = {
    for f in local.sa_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/identities/${f}"))
  }
}

module "identities" {
  source           = "../identities"
  service_accounts = local.sa_data
}
