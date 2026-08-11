# spoke - Spoke VPC, Subnet, and Shared VPC Host
Creates a spoke VPC with a primary subnet and optional GKE secondary ranges. Supports vm, gke, and mixed workload types.

## Usage
  region        = "us-central1"
  project_id    = "foundation-development"
  spoke_cidr    = "10.16.0.0/16"
  workload_type = "vm"
  subnet_cidr   = "10.16.0.0/24"
}
```
