terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # IMPORTANT: Do NOT set impersonate_service_account here.
  # The tf-executor SA does not exist yet — apply with your own credentials.
  # The provider will use your gcloud ADC (gcloud auth application-default login).
}


