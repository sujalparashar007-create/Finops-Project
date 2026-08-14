output "bucket_ids" {
  description = "Map of bucket ID to fully qualified logging bucket resource ID."
  value = {
    for name, bucket in local.created_buckets :
    name => bucket.id
  }
}

output "sink_ids" {
  description = "Map of sink name to sink resource ID."
  value = {
    for name, sink in local.created_sinks :
    name => sink.id
  }
}

output "sink_writer_identities" {
  description = "Map of sink name to writer identity. Grant these principals access on any destination not managed by this module."
  value = {
    for name, sink in local.created_sinks :
    name => sink.writer_identity
  }
}
