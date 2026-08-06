# ==============================================================================
# MODULE: finops-function — outputs
# ==============================================================================

output "function_name" {
  description = "Cloud Function name"
  value       = var.enable_function ? google_cloudfunctions2_function.alert_processor[0].name : null
}

output "function_uri" {
  description = "Cloud Function trigger URI"
  value       = var.enable_function ? google_cloudfunctions2_function.alert_processor[0].url : null
}

output "bucket_name" {
  description = "Name of the GCS bucket storing function source code"
  value       = google_storage_bucket.function_source.name
}
