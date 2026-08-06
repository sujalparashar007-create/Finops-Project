# Example: finops-foundation basic usage
# Enables APIs and grants project-level IAM for the FinOps stage.
# Run: terraform init && terraform validate

module "finops_foundation" {
  source = "../../"

  project_id = var.project_id

  activate_apis = [
    "billingbudgets.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
  ]

  iam = {
    "roles/bigquery.admin" = [
      "serviceAccount:tf-executor@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/pubsub.admin" = [
      "serviceAccount:tf-executor@${var.project_id}.iam.gserviceaccount.com",
    ]
  }
}
