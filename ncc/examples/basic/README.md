# NCC Module — Basic Example

This example demonstrates how to use the NCC module to create a Network Connectivity Center hub and attach VPC spokes.

## Usage

```hcl
module "ncc" {
  source = "../../"

  hub_project_id = "example-hub-project"
  hub_name       = "ncc-hub"
  region         = "us-central1"

  vpc_spokes = {
    spoke-prod = {
      project_id    = "example-prod-project"
      vpc_self_link = "projects/example-prod-project/global/networks/prod-vpc"
    }
    spoke-dev = {
      project_id    = "example-dev-project"
      vpc_self_link = "projects/example-dev-project/global/networks/dev-vpc"
    }
  }

  labels = {
    env       = "example"
    terraform = "true"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| hub_project_id | GCP project ID | string | n/a | yes |
| region | GCP region | string | us-central1 | no |
| hub_name | NCC hub name | string | ncc-hub | no |
| vpc_spokes | Map of spoke name to project_id and vpc_self_link | map(object) | {} | no |
| labels | Labels for NCC resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| hub_id | ID of the NCC hub |
| hub_name | Name of the NCC hub |
| hub_state | Current state of the NCC hub |
| spoke_ids | Map of spoke name to NCC spoke resource ID |
| spoke_names | Map of spoke name to NCC spoke resource name |