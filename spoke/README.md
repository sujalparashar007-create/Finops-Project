# spoke — Spoke VPC, Subnet, and Shared VPC Host

Creates a spoke VPC with a primary subnet and optional GKE secondary ranges. Supports vm, gke, and mixed workload types.

## Usage

```hcl
module "spoke" {
  source = "../spoke"

  project_id    = "example-spoke-project"
  region        = "us-central1"
  env_name      = "dev"
  spoke_cidr    = "10.16.0.0/16"
  subnet_cidr   = "10.16.0.0/24"
  workload_type = "vm"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| google | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID for the spoke VPC | string | n/a | yes |
| region | GCP region | string | n/a | yes |
| env_name | Environment name (dev/nonprod/prod) | string | n/a | yes |
| spoke_cidr | CIDR block for the spoke | string | n/a | yes |
| vpc_name | Name for the spoke VPC | string | vpc-spoke | no |
| subnet_name | Name for the primary subnet | string | sb-spoke | no |
| subnet_cidr | CIDR for the primary subnet | string | n/a | yes |
| workload_type | Workload type: vm / gke / mixed | string | vm | no |
| pod_cidr | GKE pod secondary range CIDR | string | "" | no |
| svc_cidr | GKE services secondary range CIDR | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_self_link | Self-link of the spoke VPC |
| vpc_id | ID of the spoke VPC |
| vpc_name | Name of the spoke VPC |
| subnet_self_link | Self-link of the primary subnet |
| subnet_name | Name of the primary subnet |
| subnet_cidr | CIDR of the primary subnet |
| pod_range_name | GKE pod secondary range name (empty for vm) |
| svc_range_name | GKE services secondary range name (empty for vm) |
