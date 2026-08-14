output "bucket_ids" {
  description = "Map of bucket ID to fully qualified logging bucket resource ID."
  value       = module.log_retention.bucket_ids
}

output "sink_writer_identities" {
  description = "Map of sink name to writer identity."
  value       = module.log_retention.sink_writer_identities
}
