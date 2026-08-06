variable "project_id" {
  description = "GCP project ID for the BigQuery dataset"
  type        = string
  default     = "my-project-id"
}

variable "dataset_iam" {
  description = "Dataset-level IAM bindings (role -> members)"
  type        = map(list(string))
  default = {
    "roles/bigquery.dataViewer" = ["group:finops-team@example.com"]
  }
}
