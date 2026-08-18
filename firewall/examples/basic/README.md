# Firewall Module — Basic Example

This example demonstrates how to use the firewall module to create VPC firewall rules with allow blocks.

## Usage

```hcl
module "firewall" {
  source = "../../"

  project_id    = "example-project"
  vpc_self_link = "projects/example-project/global/networks/my-vpc"

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | n/a | yes |
| vpc_self_link | Self-link of the VPC network | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| rule_ids | Map of firewall rule key to firewall rule ID |
| rule_names | Map of firewall rule key to firewall rule name |