variable "parent" {
  description = "ID of the parent resource that owns the sinks and log buckets. A bare project ID when parent_type is \"project\", a numeric folder ID when \"folder\", or a numeric organization ID when \"organization\"."
  type        = string
}

variable "parent_type" {
  description = "Type of the parent resource: project, folder, or organization."
  type        = string
  default     = "project"

  validation {
    condition     = contains(["project", "folder", "organization"], var.parent_type)
    error_message = "parent_type must be one of \"project\", \"folder\", or \"organization\"."
  }
}

variable "buckets" {
  description = "Log buckets to create, keyed by a descriptive bucket ID. locked and kms_key_name are only wired for project-level buckets by this module (locked is also a GCP API restriction to project-level; kms_key_name is a module scope choice, not an API restriction)."
  type = map(object({
    location       = optional(string, "global")
    retention_days = optional(number, 30)
    locked         = optional(bool, false)
    description    = optional(string)
    kms_key_name   = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for bucket in var.buckets : bucket.retention_days >= 1
    ])
    error_message = "Every bucket's retention_days must be at least 1."
  }
}

variable "sinks" {
  description = "Log sinks to create, keyed by a descriptive sink name."
  type = map(object({
    destination_type       = string
    destination            = string
    filter                 = optional(string)
    description            = optional(string)
    disabled               = optional(bool, false)
    include_children       = optional(bool, false)
    unique_writer_identity = optional(bool, true)
    bq_partitioned_tables  = optional(bool, false)
    grant_writer_identity  = optional(bool, true)
    exclusions = optional(map(object({
      filter      = string
      description = optional(string)
      disabled    = optional(bool, false)
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for sink in var.sinks :
      contains(["bigquery", "storage", "pubsub", "logging", "project"], sink.destination_type)
    ])
    error_message = "Every sink's destination_type must be one of \"bigquery\", \"storage\", \"pubsub\", \"logging\", or \"project\"."
  }
}
