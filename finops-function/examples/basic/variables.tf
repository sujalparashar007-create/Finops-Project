variable "project_id" {
  description = "GCP project ID for the Cloud Function"
  type        = string
  default     = "my-project-id"
}

variable "region" {
  description = "GCP region for the Cloud Function and GCS bucket"
  type        = string
  default     = "us-east1"
}

variable "pubsub_topic_id" {
  description = "Full Pub/Sub topic ID to trigger the Cloud Function"
  type        = string
  default     = "projects/my-project/topics/finops-budget-alerts"
}

variable "function_source_dir" {
  description = "Path to directory containing main.py and requirements.txt"
  type        = string
  default     = "./function-source"
}

variable "bucket_name" {
  description = "GCS bucket name for storing function source code"
  type        = string
  default     = "finops-function-source"
}

variable "service_account_email" {
  description = "Service account email for the Cloud Function runtime"
  type        = string
  default     = "tf-executor@my-project.iam.gserviceaccount.com"
}

variable "secret_environment" {
  description = "Sensitive values stored in Secret Manager"
  type        = map(string)
  default     = {}
}
