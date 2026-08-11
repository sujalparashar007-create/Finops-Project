# firewall - VPC Firewall Rules

Creates VPC firewall rules with support for multiple allow/deny blocks, service accounts, tags, and both ingress/egress directions.

## Usage

```hcl
module "firewall" {
  source = "../firewall"

  project_id    = "my-project"
  vpc_self_link = "projects/my-project/global/networks/my-vpc"

  rules = {
    allow_ssh = {
      name          = "allow-ssh"
      description   = "Allow SSH from anywhere"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  }
}
```

## Requirements

- Terraform 1.5+
- Google Provider 6.0+

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID where the VPC firewall rules will be created | string | n/a | yes |
| vpc_self_link | Self-link of the VPC network to apply firewall rules to | string | n/a | yes |
| rules | Map of firewall rules to create | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| rule_ids | Map of firewall rule key to firewall rule ID |
| rule_names | Map of firewall rule key to firewall rule name |
