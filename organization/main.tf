# ==============================================================================
# MODULE: organization — GCP Organization Data + Tags
# ==============================================================================
# Represents the existing GCP Organization (data-only; orgs are not created
# by Terraform) and binds pre-existing Resource Manager Tags to it.
#
# Org-level IAM is handled separately via the standalone `iam` module
# (scope = "organization").
# ==============================================================================

data "google_organization" "org" {
  organization = var.org_id
}

# Bind pre-existing tag values to the organization resource.
resource "google_tags_tag_binding" "org_tags" {
  for_each = var.tags

  parent    = "//cloudresourcemanager.googleapis.com/organizations/${var.org_id}"
  tag_value = "tagValues/${each.value}"
}
