provider "google" {
  project                     = var.project_id
  billing_project             = var.project_id
  region                      = var.region
  impersonate_service_account = "tf-executor@${var.project_id}.iam.gserviceaccount.com"
}
