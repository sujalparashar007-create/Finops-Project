# Example: finops-function basic usage
# Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts.
# Secrets (e.g. Teams webhook) stored in Secret Manager.
# Run: terraform init && terraform validate

module "finops_function" {
  source = "../../"

  project_id          = var.project_id
  region              = var.region
  pubsub_topic_id     = var.pubsub_topic_id
  function_name       = "finops-budget-alert-processor"
  function_source_dir = var.function_source_dir
  bucket_name         = var.bucket_name

  existing_service_account_email = var.service_account_email

  environment_variables = {}

  secret_environment = var.secret_environment
}
