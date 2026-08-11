# Deploy — Staged Hub-and-Spoke Landing Zone

This `deploy/` tree is the **orchestration glue** for the FINOPS-PROJECT modules.
It follows the same staged, remote-state-linked deployment model as the proven
`terraform-google-foundation` reference: each stage is its own root config with
its own GCS remote state, and later stages read earlier stages' outputs via
`data "terraform_remote_state"`.

The modules themselves are **not** modified — they are consumed here as-is.

## Stage order (deploy strictly in this sequence)

```
 ┌────────────────────────────────────────────────────────────┐
 │ 01-folders-host-projects   (human creds, no impersonation) │
 │     folder/ + project/  →  folders + host projects + SAs   │
 └───────────────────────────────┬────────────────────────────┘
                                 ▼
 ┌────────────────────────────────────────────────────────────┐
 │ 02-hub-spoke                 (impersonate hub tf-executor) │
 │     hub/ + spoke/ + peering|ncc + firewall                 │
 └───────────────────────────────┬────────────────────────────┘
                                 ▼
 ┌────────────────────────────────────────────────────────────┐
 │ 03-service-projects          (impersonate hub tf-executor) │
 │     project/ + shared-vpc attach + VM on host subnets      │
 └────────────────────────────────────────────────────────────┘
```

| Stage | Runs as | Creates | Consumes state from |
|-------|---------|---------|---------------------|
| `01` | Your user (ADC) | folders, host projects, `tf-executor` SAs, IAM | — |
| `02` | `tf-executor` (hub project) | hub VPC/subnet/router, spoke VPCs/subnets, peering or NCC, firewall | `01` |
| `03` | `tf-executor` (hub project) | service projects, Shared VPC attachment, VMs | `01`, `02` |

## State bucket

All stages share one GCS state bucket, one prefix per stage:

| Stage | Backend prefix |
|-------|----------------|
| `01` | `01-folders-host-projects` |
| `02` | `02-hub-spoke` |
| `03` | `03-service-projects` |

> **You must create the bucket before running any stage** (the modules can't
> create their own backend). Default bucket set in `backend.tf`:
> `gs://finops-foundation-tfstate`. Create with:
> ```powershell
> gcloud storage buckets create gs://finops-foundation-tfstate
> ```
> If you use a different name, change `bucket` in every `backend.tf`.

## Prerequisites

```powershell
gcloud auth login                       # org admin / project creator + billing access
gcloud auth application-default login  # Terraform provider credentials (Stage 01)
```

Fill in your real values in each stage's `terraform.tfvars`
(`org_id`, `billing_account_id`, `terraform_user`, project IDs, subnets, etc.).
The checked-in values mirror the module `examples/basic/` for convenience —
**do not commit secrets or real customer values.**

## How to run each stage

```powershell
# Stage 01 — human creds (tf-executor SAs don't exist yet)
cd deploy\01-folders-host-projects
terraform init
terraform plan
terraform apply -auto-approve

# Stage 02 — impersonates the hub project's tf-executor SA
cd ..\02-hub-spoke
terraform init
terraform plan
terraform apply -auto-approve

# Stage 03 — impersonates the hub project's tf-executor SA
cd ..\03-service-projects
terraform init
terraform plan
terraform apply -auto-approve
```

(`terraform init` is only needed once per stage; re-run with `-reconfigure`
only if the backend config changes.)

## Permissions required on the impersonated SA

`tf-executor` (hub project) drives Stages 02 and 03. Because it creates VPCs in
the spoke project and attaches service projects to other hosts, it needs
cross-project networking privileges in addition to what `host-projects`
grants it today. Grant at least these on the **hub project's** `tf-executor`
(or at org level, matching the reference foundation):

- `roles/compute.networkAdmin`
- `roles/compute.xpnAdmin`
- `roles/compute.instanceAdmin.v1`
- `roles/iam.serviceAccountUser`

> If your `project` module is invoked with `org_iam_roles`, those can be listed
> there instead of granting a role list on one project. (Modules are not edited
> here per the task constraint — handle permissions as part of your IAM stage.)

## What to validate after deploy

- Stage 01: folders + host projects visible, each with a `tf-executor` SA.
- Stage 02: `vpc-hub`/`sb-hub` + each `vpc-spoke` (routing mode `GLOBAL`); VPC
  network peering shows **ACTIVE** (or NCC hub/spokes `ACTIVE`); firewall rules present.
- Stage 03: service projects attached to each host's Shared VPC; VMs' network
  interfaces reference the host subnets. SSH (IAP) from `net-vm` → `ping`/SSH the
  spoke VM's internal IP to prove hub↔spoke traffic.