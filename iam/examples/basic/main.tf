# =============================================================================
# EXAMPLE: iam module — basic usage
# =============================================================================
# Standalone root module that grants additive project-level IAM bindings.
# Run: cd examples/basic && terraform init && terraform apply
# =============================================================================

# Replace the empty map below with real grants, e.g.:
#
# iam_bindings_additive = {
#   viewer = {
#     member = "group:gcp-viewers@example.com"
#     role   = "roles/viewer"
#   }
# }
module "project_iam" {
  source      = "../../"
  scope       = "project"
  resource_id = var.project_id

  iam_bindings_additive       = {}
  enable_conditional_bindings = false
}
