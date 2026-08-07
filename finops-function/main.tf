# ==============================================================================
# MODULE: finops-function > Budget Alert Cloud Function (2nd gen)
# ==============================================================================

# GCS bucket to store the Cloud Function source code
resource "google_storage_bucket" "function_source" {
  name     = var.bucket_name
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = true
}

# Zip the function source code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = var.function_source_dir
  output_path = "${path.module}/function-source.zip"
}

# Upload the zip to GCS
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-${data.archive_file.function_zip.output_sha256}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_zip.output_path
}

# ------------------------------------------------------------------------------
# SECRET MANAGER > store sensitive credentials instead of plaintext env vars
# ------------------------------------------------------------------------------

resource "google_secret_manager_secret" "secrets" {
  for_each = { for k, v in var.secret_environment : k => v if !contains(keys(var.existing_secret_ids), k) }

  secret_id = "${var.function_name}-${each.key}"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    managed_by = "terraform"
  }
}

resource "google_secret_manager_secret_version" "versions" {
  for_each = { for k, v in var.secret_environment : k => v if !contains(keys(var.existing_secret_ids), k) }

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value

  depends_on = [google_secret_manager_secret.secrets]
}

# Grant the Cloud Function SA access to read the secrets
resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each = var.secret_environment

  secret_id = google_secret_manager_secret.secrets[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account_email}"
}

# Grant additional members (e.g. human users) access to read specific secrets
resource "google_secret_manager_secret_iam_member" "additional_accessors" {
  for_each = { for entry in var.secret_accessors : "${entry.secret_key}/${entry.member}" => entry }

  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}

# Project lookup (needed for Compute Engine default SA email)
data "google_project" "project" {
  project_id = var.project_id
}

# Dedicated runtime service account (created only when no existing SA is supplied)
resource "google_service_account" "function_runtime" {
  count = var.existing_service_account_email == null ? 1 : 0

  project      = var.project_id
  account_id   = "${replace(var.function_name, "finops-budget-alert", "fba")}-sa"
  display_name = "Runtime SA for ${var.function_name} (finops-function module)"
}

locals {
  create_service_account = var.existing_service_account_email == null

  service_account_email = (
    var.existing_service_account_email != null
    ? var.existing_service_account_email
    : google_service_account.function_runtime[0].email
  )

  # Compute Engine default SA — used by Eventarc trigger when service_account_email is not set
  compute_default_sa = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  # All secret IDs (newly-created + caller-supplied existing ones)
  secret_ids = merge(
    { for k, v in google_secret_manager_secret.secrets : k => v.secret_id },
    var.existing_secret_ids
  )
}

# Grant Eventarc permission to invoke the Cloud Run service via the Compute Engine default SA
resource "google_cloud_run_service_iam_member" "eventarc_invoker" {
  count    = var.enable_function ? 1 : 0
  project  = var.project_id
  location = var.region
  service  = var.function_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${local.compute_default_sa}"

  depends_on = [google_cloudfunctions2_function.alert_processor]
}

# Grant the dedicated runtime SA roles if specified
resource "google_project_iam_member" "runtime_sa_roles" {
  for_each = local.create_service_account ? toset(var.runtime_sa_roles) : toset([])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.function_runtime[0].email}"
}

resource "google_cloudfunctions2_function" "alert_processor" {
  count       = var.enable_function ? 1 : 0
  name        = var.function_name
  location    = var.region
  project     = var.project_id
  description = "Processes budget alert messages from Pub/Sub and logs them to Cloud Logging"

  build_config {
    runtime     = var.runtime
    entry_point = "process_budget_alert"

    source {
      storage_source {
        bucket = google_storage_bucket_object.function_zip.bucket
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count    = var.max_instance_count
    available_memory      = var.available_memory
    timeout_seconds       = var.timeout_seconds
    service_account_email = local.service_account_email

    environment_variables = var.environment_variables

    dynamic "secret_environment_variables" {
      for_each = var.secret_environment
      content {
        key        = secret_environment_variables.key
        project_id = var.project_id
        secret     = local.secret_ids[secret_environment_variables.key]
        version    = "latest"
      }
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.pubsub_topic_id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }

  depends_on = [
    google_secret_manager_secret_version.versions
  ]
}



