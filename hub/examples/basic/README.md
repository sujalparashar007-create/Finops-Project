# Hub Module — Basic Example

This example demonstrates how to use the hub module to create a hub VPC, subnet, and Cloud Router.

## Usage

```hcl
module "hub" {
  source = "../../"

  project_id  = "example-hub-project"
  region      = "us-central1"
  hub_cidr    = "10.0.0.0/20"
  subnet_cidr = "10.0.0.0/24"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | n/a | yes |
| region | GCP region | string | us-central1 | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created hub VPC | "
