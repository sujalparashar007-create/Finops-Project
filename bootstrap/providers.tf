# ==============================================================================
# ROOT MODULE: bootstrap — providers
# ==============================================================================
# IMPORTANT: Do NOT set impersonate_service_account here. The tf-executor SA
# does not exist yet. Apply with your own credentials via gcloud ADC
# (gcloud auth application-default login).
# ==============================================================================

provider "google" {
  # Uses your gcloud ADC credentials.
}