# log-retention

Creates Cloud Logging **sinks** (log routers) and **log buckets** with
retention, immutability, and CMEK support, at project, folder, or organization
scope. This is the module for durable, tamper-resistant log storage and for
routing logs to long-term destinations (log buckets, Cloud Storage, BigQuery,
Pub/Sub).

## What this module does

- Creates zero or more **log buckets** (`google_logging_*_bucket_config`) with
  a configurable retention period, optional `locked` immutability, and optional
  CMEK.
- Creates zero or more **log sinks** (`google_logging_*_sink`) that route
  matching logs to a destination, with optional `include_children` for
  aggregated folder/organization sinks.
- Optionally grants each sink's **writer identity** the least-privilege role on
  Cloud Storage, BigQuery, and Pub/Sub destinations.

The `parent_type` variable selects the scope; one set of resources is created
per scope, so the same module works for a single project or for centralized
landing-zone logging at the folder/organization level.

## Immutability (`locked`)

Setting a bucket's `locked = true` prevents its retention period from being
reduced and prevents the bucket from being deleted until it is empty. This is
a one-way action - plan retention carefully before locking.

`kms_key_name` (CMEK) is supported by the GCP API at all three scopes, but
this module currently only wires it for **project-level** buckets - a scope
decision, not an API limitation. `locked` genuinely is project-only in the
GCP API itself.

## Destinations

Supply the plain resource ID in `destination`; the module builds the full
`<service>.googleapis.com/<id>` URI based on `destination_type`:

| destination_type | destination format | writer role granted |
|---|---|---|
| `storage` | `my-bucket-name` | `roles/storage.objectCreator` |
| `bigquery` | `projects/PROJECT/datasets/DATASET` | `roles/bigquery.dataEditor` |
| `pubsub` | `projects/PROJECT/topics/TOPIC` | `roles/pubsub.publisher` |
| `logging` | `projects/PROJECT/locations/LOCATION/buckets/BUCKET` | granted by caller |
| `project` | `PROJECT` | granted by caller |

For `logging` and `project` destinations, grant the writer identity (exposed via
the `sink_writer_identities` output) yourself.

## Usage

See `examples/basic/` for a complete, runnable example. Minimal shape:

```hcl
module "log_retention" {
  source = "../log-retention"

  parent      = "my-logging-project"
  parent_type = "project"

  buckets = {
    "audit-logs" = {
      retention_days = 400
      locked         = true
    }
  }

  sinks = {
    "audit-to-bucket" = {
      destination_type = "logging"
      destination      = "projects/my-logging-project/locations/global/buckets/audit-logs"
      filter           = "logName:\"cloudaudit.googleapis.com\""
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| parent | Parent resource ID (project ID, folder ID, or org ID). | `string` | n/a | yes |
| parent_type | Parent type: `project`, `folder`, or `organization`. | `string` | `"project"` | no |
| buckets | Map of log buckets to create, keyed by bucket ID. | `map(object)` | `{}` | no |
| sinks | Map of log sinks to create, keyed by sink name. | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| bucket_ids | Map of bucket ID to fully qualified logging bucket resource ID. |
| sink_ids | Map of sink name to sink resource ID. |
| sink_writer_identities | Map of sink name to writer identity. |
