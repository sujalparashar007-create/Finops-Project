# Grant each opted-in sink's writer identity the least-privilege role needed to
# write to its destination. Bindings are additive (_iam_member) so they coexist
# with other automation managing the destination resource. Grants for "logging"
# and "project" destination types are intentionally left to the caller, since
# those require resource-scoped conditions or cross-project context this module
# does not own.

resource "google_storage_bucket_iam_member" "storage_writer" {
  for_each = local.storage_sinks

  bucket = each.value.destination
  role   = "roles/storage.objectCreator"
  member = local.created_sinks[each.key].writer_identity
}

resource "google_bigquery_dataset_iam_member" "bigquery_writer" {
  for_each = local.bigquery_sinks

  project    = split("/", each.value.destination)[1]
  dataset_id = split("/", each.value.destination)[3]
  role       = "roles/bigquery.dataEditor"
  member     = local.created_sinks[each.key].writer_identity
}

resource "google_pubsub_topic_iam_member" "pubsub_writer" {
  for_each = local.pubsub_sinks

  project = split("/", each.value.destination)[1]
  topic   = split("/", each.value.destination)[3]
  role    = "roles/pubsub.publisher"
  member  = local.created_sinks[each.key].writer_identity
}
