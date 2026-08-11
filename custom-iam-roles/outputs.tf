# ==============================================================================
# MODULE: custom-iam-roles — outputs
# ==============================================================================

output "custom_role_ids" {
  description = "Fully-qualified custom role IDs, ready to reference in any module's iam_bindings_additive.role"
  value = merge(
    { for k, v in google_organization_iam_custom_role.role : k => v.id },
    { for k, v in google_project_iam_custom_role.role : k => v.id },
  )
}
