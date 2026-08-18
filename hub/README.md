# hub — Hub VPC, Subnet, and Cloud Router

Creates a hub VPC with a single subnet and a Cloud Router for hub-and-spoke networking.

## Usage

```hcl
module "hub" {
  source = "../hub"

  project_id  = "example-hub-project"
  region      = "us-central1"
  hub_cidr    = "10.0.0.0/20"
  subnet_cidr = "10.0.0.0/24"
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
| project_id | GCP project ID where the hub VPC will be created | string | n/a | yes |
| region | GCP region for the hub | string | n/a | yes |
| hub_cidr | CIDR block reserved for the hub | string | 10.0.0.0/20 | no |
| subnet_cidr | Primary hub subnet CIDR | string | 10.0.0.0/24 | no |
| subnet_name | Name for the hub subnet | string | sb-hub | no |
| vpc_name | Name for the hub VPC | string | vpc-hub | no |
| router_name | Name for the Cloud Router | string | cr-hub | no |
| router_asn | BGP ASN for the Cloud Router | number | 64514 | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_self_link | Self-link of the hub VPC |
| vpc_id | ID of the hub VPC |
| vpc_name | Name of the hub VPC |
| subnet_self_link | Self-link of the hub subnet |
| subnet_name | Name of the hub subnet |
| subnet_cidr | CIDR range of the hub subnet |
| router_self_link | Self-link of the Cloud Router |
| router_name | Name of the Cloud Router |
| router_asn | BGP ASN of the Cloud Router |
| region | Region where hub resources are deployed | "
