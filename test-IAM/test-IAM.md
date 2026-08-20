# test-IAM — Bootstrap & Factory Overview

Purpose

This module is the Stage‑0 bootstrap for the FinOps workspace. It creates a bootstrap host project (the Terraform execution host) and, from YAML-driven factory files, provisions FinOps folders, projects, and service accounts used by FinOps workloads.

Deployed resources

Bootstrap (control/execution path)
- Folder: `bootstrap-finops` (created only if `var.folder_id` is empty)
- Project: bootstrap host project (`var.project_id`)
- Service account: `tf-executor` in the bootstrap project
- Project-level IAM roles granted to `tf-executor`
- Billing IAM: `tf-executor` → `roles/billing.admin`
- Human impersonation grant: `roles/iam.serviceAccountTokenCreator` on `tf-executor`
- Optional API enablement (`activate_apis`)

Factory (YAML-driven persistent FinOps resources)
- Folder(s) from `hierarchical-iam.yaml` (e.g. `finops-foundation`)
- Project(s) from `projects.yaml` (e.g. `finops-foundation-test-0001`)
- Service accounts and role grants from `identities.yaml`
- Additive IAM at folder/project scope via the `iam` module

How inputs are passed

- YAML files in this module are read with `yamldecode(file(path))` into locals, then passed to `module "factory_projects"`, `module "factory_folders"`, and `module "factory_identities"`.

Operational notes

- Both bootstrap and factory paths are intentional and serve different responsibilities: bootstrap is the execution host; factory contains the persistent FinOps resources.
- To avoid creating the bootstrap folder, set `var.folder_id` to an existing folder ID before apply.

Files of interest

- `main.tf` (root orchestration)
- `projects.yaml`, `identities.yaml`, `hierarchical-iam.yaml`
- Related modules: `../projects`, `../folder`, `../identities`, `../iam`
