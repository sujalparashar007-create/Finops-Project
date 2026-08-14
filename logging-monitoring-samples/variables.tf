variable "project_id" {
  description = "Project ID where the sample log-based metrics and dashboards are created."
  type        = string
}

variable "logging_metrics" {
  description = "Log-based metrics to create, keyed by metric name. Defaults to a set of sample security metrics; pass {} to create none."
  type = map(object({
    filter           = string
    description      = optional(string)
    value_extractor  = optional(string)
    label_extractors = optional(map(string), {})
    metric_descriptor = optional(object({
      metric_kind  = string
      value_type   = string
      display_name = optional(string)
      unit         = optional(string)
    }))
  }))
  default = {
    "denied-firewall-hits" = {
      description = "Count of packets denied by VPC firewall rules (sample)."
      filter      = "resource.type=\"gce_subnetwork\" AND jsonPayload.disposition=\"DENIED\""
    }
    "iam-policy-changes" = {
      description = "Count of SetIamPolicy calls across the project (sample)."
      filter      = "protoPayload.methodName=\"SetIamPolicy\""
    }
  }
}

variable "create_dashboards" {
  description = "Whether to create the sample monitoring dashboards bundled in the dashboards/ directory."
  type        = bool
  default     = true
}
