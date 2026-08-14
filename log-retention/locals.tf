locals {
  # Cloud Logging expects a sink destination of the form
  # "<service>.googleapis.com/<resource-id>". Map each destination type to its
  # service host so callers only supply the plain resource ID.
  service_by_destination_type = {
    bigquery = "bigquery.googleapis.com"
    storage  = "storage.googleapis.com"
    pubsub   = "pubsub.googleapis.com"
    logging  = "logging.googleapis.com"
    project  = "logging.googleapis.com"
  }

  sinks = {
    for name, sink in var.sinks :
    name => merge(sink, {
      destination_uri = "${local.service_by_destination_type[sink.destination_type]}/${sink.destination}"
    })
  }

  # Single map of all created sinks regardless of parent type, used for outputs
  # and destination IAM. Only one of the three maps is ever populated.
  created_sinks = merge(
    google_logging_project_sink.project_sink,
    google_logging_folder_sink.folder_sink,
    google_logging_organization_sink.organization_sink,
  )

  created_buckets = merge(
    google_logging_project_bucket_config.project_bucket,
    google_logging_folder_bucket_config.folder_bucket,
    google_logging_organization_bucket_config.organization_bucket,
  )

  # Sinks that opt in to having their writer identity granted access on the
  # destination, split by destination type for least-privilege IAM bindings.
  writer_sinks   = { for name, sink in local.sinks : name => sink if sink.grant_writer_identity }
  storage_sinks  = { for name, sink in local.writer_sinks : name => sink if sink.destination_type == "storage" }
  bigquery_sinks = { for name, sink in local.writer_sinks : name => sink if sink.destination_type == "bigquery" }
  pubsub_sinks   = { for name, sink in local.writer_sinks : name => sink if sink.destination_type == "pubsub" }
}
