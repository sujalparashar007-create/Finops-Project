# ==============================================================================
# STAGE 01: providers — human credentials (ADC)
# ==============================================================================
# The tf-executor SAs are created by this stage, so this stage must run as the
# human operator via gcloud auth application-default login. Do NOT set
# impersonate_service_account here.
# ==============================================================================
provider "google" {
  # region/folder are not required for bootstrap; pass-through only.
}
