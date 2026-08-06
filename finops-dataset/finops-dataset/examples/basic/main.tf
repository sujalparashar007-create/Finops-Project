# Example: finops-dataset basic usage
# Creates a BigQuery dataset for FinOps reporting views with IAM bindings.
# Run: terraform init && terraform validate

module "finops_dataset" {
  source = "../../"

  project_id = var.project_id
  dataset_id = "billing_export"
  location   = "EU"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  iam = var.dataset_iam
}
