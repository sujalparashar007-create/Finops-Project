# finops-foundation — Basic Example

Minimal example that enables APIs and grants project-level IAM for a FinOps project.

## Usage

```hcl
module "finops_foundation" {
  source = "../../"

  project_id = "my-project-id"

  activate_apis = [
    "billingbudgets.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
  ]

  iam = {
    "roles/bigquery.admin" = [
      "serviceAccount:tf-executor@my-project-id.iam.gserviceaccount.com",
    ]
    "roles/pubsub.admin" = [
      "serviceAccount:tf-executor@my-project-id.iam.gserviceaccount.com",
    ]
  }
}
```

## Run

```bash
cd finops-foundation/examples/basic
terraform init
terraform validate
terraform plan
```

## What it creates

- `google_project_service` — APIs enabled on the project (F13)
- `google_project_iam_member` — Additive IAM grants at project level (F7)

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | `"my-project-id"` | GCP project ID to configure |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID (passthrough) |
