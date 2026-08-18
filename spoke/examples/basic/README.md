# Spoke Module — Basic Example

This example demonstrates how to use the spoke module to create a spoke VPC and subnet for VM workloads.

## Usage

```hcl
module "spoke" {
  source = "../../"

  project_id    = "example-spoke-project"
  region        = "us-central1"
  env_name      = "dev"
  spoke_cidr    = "10.16.0.0/16"
  subnet_cidr   = "10.16.0.0/24"
  workload_type = "vm"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | n/a | yes |
| region | GCP region | string | us-central1 | no |
| env_name | Environment name | string | dev | no |
| spoke_cidr | Spoke CIDR | string | 10.16.0.0/16 | no |
| subnet_cidr | Subnet CIDR | string | 10.16.0.0/24 | no |
| workload_type | Workload type | string | vm | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created spoke VPC |
| subnet_cidr | CIDR of the created spoke subnet |