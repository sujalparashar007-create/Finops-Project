variable "project_id" {
  description = "GCP project ID for the BigQuery dataset"
  type        = string
  default     = "my-project-id"
}

variable "dataset_iam" {
  description = "Dataset-level IAM bindings as list of role/member entries"
  type = list(object({
    role   = string
    member = string
  }))
  default = [
    { role = "roles/bigquery.dataViewer", member = "group:finops-team@example.com" },
  ]
}

