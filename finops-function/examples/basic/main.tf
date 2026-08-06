# Example: finops-function basic usage
# Deploys a Cloud Function (2nd gen) triggered by Pub/Sub budget alerts.
# Secrets (Gmail password, Teams webhook) stored in Secret Manager.
# Run: terraform init && terraform validate

module "finops_function" {
  source = "../../"

  project_id          = var.project_id
  region              = var.region
  pubsub_topic_id     = var.pubsub_topic_id
  function_name       = "finops-budget-alert-processor"
  function_source_dir = var.function_source_dir
  bucket_name         = var.bucket_name

  service_account_email = var.service_account_email

  environment_variables = {
    GMAIL_USER = "alerts@example.com"
  }

  secret_environment = var.secret_environment
}
