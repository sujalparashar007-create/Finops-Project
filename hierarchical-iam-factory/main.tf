# ==============================================================================
# MODULE: hierarchical-iam-factory — YAML-Driven Folder/Org IAM Factory
# ==============================================================================
# Creates folders and folder/org-level IAM bindings from YAML. Used to scale
# hierarchical IAM without editing Terraform code for every folder/binding.
# ==============================================================================

locals {
  hier_iam_files = fileset("${path.module}/factories/hierarchical-iam", "*.yaml")
  hier_iam_data = {
    for f in local.hier_iam_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/hierarchical-iam/${f}"))
  }
}

module "folders" {
  source  = "../folder"
  folders = var.folders
}

module "folder_iam" {
  source   = "../iam"
  for_each = { for k, v in local.hier_iam_data : v.folder_name => v.bindings }

  scope                 = "folder"
  resource_id            = module.folders.folder_ids[each.key]
  iam_bindings_additive  = each.value

  depends_on = [module.folders]
}