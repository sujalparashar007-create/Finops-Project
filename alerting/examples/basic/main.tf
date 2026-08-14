module "alerting" {
  source = "../.."

  project_id = var.project_id

  notification_channels = {
    "ops-email" = {
      type        = "email"
      description = "Primary operations email (Terraform-managed)."
      labels      = { email_address = var.alert_email }
    }
  }

  alert_policies = {
    "iam-policy-changes" = {
      display_name          = "IAM policy changes"
      notification_channels = ["ops-email"]
      documentation = {
        content = "A SetIamPolicy call was observed. Verify the change was expected."
      }
      conditions = [{
        display_name = "IAM setIamPolicy calls"
        condition_matched_log = {
          filter = "protoPayload.methodName=\"SetIamPolicy\""
        }
      }]
    }
  }
}
