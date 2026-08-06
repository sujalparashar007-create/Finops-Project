# finops-foundation — IAM + API Enablement

Handles project-level IAM grants (F7) and consolidated API enablement (F13) for the FinOps stage. Keeps these concerns separated from the generic `modules/project`.

## Usage

```hcl
module "finops_foundation" {
  source = "../finops-foundation"

  project_id = "myco-finops-abc123"

  activate_apis = [
    "billingbudgets.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
  ]

  iam = {
    "roles/bigquery.admin" = [
      "serviceAccount:tf-executor@myco-finops-abc123.iam.gserviceaccount.com",
    ]
    "roles/pubsub.admin" = [
      "serviceAccount:tf-executor@myco-finops-abc123.iam.gserviceaccount.com",
    ]
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP project ID hosting FinOps resources |
| `activate_apis` | `list(string)` | `[]` | GCP APIs to enable (F13 — consolidated) |
| `iam` | `map(list(string))` | `{}` | Project-level IAM bindings (F7 — additive) |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID (passthrough) |
