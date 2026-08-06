# ==============================================================================
# MODULE: secret-manager — Secret Manager Secrets, Versions & IAM
# ==============================================================================
# Single-responsibility module for creating Secret Manager secrets, storing
# versioned payloads, and granting secretAccessor IAM to specified members.
#
# Usage:
#   module "finops_secrets" {
#     source = "../secret-manager"
#     project_id = "my-project-id"
#     secrets = {
#       "my-app-db-password" = var.db_password
#       "my-app-api-key"     = var.api_key
#     }
#     accessors = [
#       "serviceAccount:my-function-sa@my-project.iam.gserviceaccount.com",
#     ]
#   }
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. SECRET MANAGER SECRETS
# ------------------------------------------------------------------------------
resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  secret_id = each.key
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    managed_by = "terraform"
  }
}

# ------------------------------------------------------------------------------
# 2. SECRET VERSIONS — store the actual payload
# ------------------------------------------------------------------------------
resource "google_secret_manager_secret_version" "versions" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value

  depends_on = [google_secret_manager_secret.secrets]
}

# ------------------------------------------------------------------------------
# 3. IAM — grant secretAccessor to each specified member on every secret
# ------------------------------------------------------------------------------
resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each = {
    for pair in flatten([
      for secret_name in keys(var.secrets) : [
        for member in var.accessors : {
          secret = secret_name
          member = member
        }
      ]
    ]) : "${pair.secret}/${pair.member}" => pair
  }

  secret_id = google_secret_manager_secret.secrets[each.value.secret].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}
