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
  for_each = var.secret_environment

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
  for_each = var.secret_environment

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

# Grant Eventarc permission to invoke the Cloud Run service (not allUsers)
resource "google_cloud_run_service_iam_member" "pubsub_invoker" {
  count    = var.enable_function ? 1 : 0
  project  = var.project_id
  location = var.region
  service  = var.function_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${local.eventarc_service_agent}"

  depends_on = [google_cloudfunctions2_function.alert_processor]
}

# ------------------------------------------------------------------------------
# CLOUD FUNCTION
# ------------------------------------------------------------------------------

# Look up the project number (needed for Eventarc service agent email)
data "google_project" "project" {
  project_id = var.project_id
}

# Dedicated runtime service account (CFF pattern)
resource "google_service_account" "function_runtime" {
  count = var.create_service_account ? 1 : 0

  project      = var.project_id
  account_id   = "${replace(var.function_name, "finops-budget", "fb")}-sa"
  display_name = "Runtime SA for ${var.function_name} (finops-function module)"
}

locals {
  service_account_email = (
    var.create_service_account
    ? google_service_account.function_runtime[0].email
    : var.service_account_email
  )

  # Eventarc service agent — the only identity that should invoke the Cloud Run service
  eventarc_service_agent = "service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}

# Grant the dedicated runtime SA roles if specified
resource "google_project_iam_member" "runtime_sa_roles" {
  for_each = var.create_service_account ? toset(var.runtime_sa_roles) : toset([])

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
    runtime         = var.runtime
    entry_point     = "process_budget_alert"
    service_account = "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"

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
        secret     = google_secret_manager_secret.secrets[secret_environment_variables.key].secret_id
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



