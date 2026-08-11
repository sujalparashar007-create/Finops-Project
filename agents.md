# AGENTS.md
 
Instructions for AI coding agents working in this repository.
 
## What this is
 
A Terraform starter pack for building a GCP landing zone for a customer:

resource hierarchy, governance, IAM, networking, logging, monitoring, and

cost management modules. Modules here are meant to be reused across customer

engagements — write for the next engineer/agent who picks this up cold, not

just for the current task.
 
## Before creating or editing a module
 
1. Read `BESTPRACTICES.md` in this repo root — it's the actual style guide

   (naming, structure, IAM patterns, flexibility vs. over-engineering). Every

   module you create or touch must follow it.

2. NA

3. Check the repo root for an existing module directory covering the same

   or adjacent resource before creating a new one (each module is its own

   top-level directory, e.g. `network/`, `iam/`, `logging/` — not nested

   under a `modules/` folder). Extend an existing module if the resource

   fits its stated responsibility; create a new one if it doesn't.

4. Identify the module's single responsibility before writing any code

   (e.g. "creates a Shared VPC host project and subnets" — not "networking

   and IAM and logging").
 
## Creating a new module — checklist
 
- [ ] One clear responsibility, named accordingly, as its own top-level

      directory at the repo root (e.g. `network/`, `iam/`, `logging/`).

- [ ] Standard files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`,

      `README.md`. Split `main.tf` into topic files if it grows large.

- [ ] Every variable has a `type` and a `description`. Add `validation`

      blocks for values that would otherwise fail late or unclearly.

- [ ] Every resource/module block name is descriptive of what it represents,

      not a restatement of its resource type or a placeholder like `this`.

- [ ] No nested loops or multi-level conditional nesting — if the logic

      needs that, restructure the input variable shape instead.

- [ ] IAM bindings scoped to least privilege, at the narrowest resource

      level that makes sense; additive (`_iam_member`) unless the module is

      explicitly meant to own the whole binding list.

- [ ] Provider/module version constraints pinned in `versions.tf`.

- [ ] An `examples/basic/` directory with a small, runnable root module that

      calls this module — not just a code block in the README.

- [ ] `README.md` written: purpose, inputs, outputs, minimal usage example.

- [ ] `terraform fmt` and `terraform validate` run clean.

- [ ] `terraform plan` reviewed against a real or sandbox project — don't

      stop at `validate` passing.
 
## What "good" looks like here
 
Simple and a little repetitive beats clever and compact. Duplicate blocks

are acceptable; deeply nested loops or conditionals are not. Flexibility

should come from well-designed variables (with sensible defaults), not from

exposing every possible resource attribute "just in case." See

`BESTPRACTICES.md` for the full reasoning behind each of these.
 
## Commit and PR expectations
 
- Don't commit `.tfvars` files containing real customer values, credentials,

  or secrets.

- Keep commits scoped to one module or one logical change.

- Don't reference `main`/`master` for any module source — pin to a tag or

  commit SHA.
 
 
BEST_PRACTICES.md
 
Terraform Module Best Practices

Guidelines for writing Terraform modules in this repository. This is a GCP landing zone starter pack — modules here get reused across customer engagements, so consistency and readability matter more than cleverness.
 
Simplicity over cleverness

Prefer simple, explicit code over compact, clever code. A module that's a bit repetitive but easy to read beats one that's short but hard to follow.

Duplicate or redundant blocks are fine. Don't introduce an abstraction just to avoid repeating a few lines.

Avoid complex loops. for_each/count over a flat list or map is fine. Nested loops (a for_each producing another for_each, or deeply nested for expressions) are not — if you need one, restructure the input data instead of nesting the logic.

Avoid deep conditional nesting (try() wrapped in try(), multi-level ? :). One level of conditional logic is usually enough; if you need more, the variable design is probably wrong.

Don't build a feature "because it might be needed later." Add flexibility when a real use case needs it, not speculatively.

Naming

Resource and module block names must be descriptive and state what the resource is, not restate its type.

Good: resource "google_compute_network" "landing_zone_vpc"

Avoid: resource "google_compute_network" "this" / resource "google_compute_network" "vpc1"

Variable and output names should read naturally in context: var.network_name, not var.name inside a networking module where "name" is ambiguous.

Be consistent within a module — don't mix snake_case and abbreviations arbitrarily (svc_acct in one place, service_account in another).

Prefix booleans clearly: enable_*, create_*, is_*.

Module structure

Standard file layout: main.tf, variables.tf, outputs.tf, versions.tf, README.md. Split main.tf into topic files (iam.tf, network.tf) once it gets long — don't force everything into one file.

One module = one clear responsibility. If a module is doing IAM, networking, and logging all at once, split it.

No hardcoded values that vary by environment or customer — those belong in variables with sensible defaults, not baked into resource blocks.

Flexibility without over-engineering

A module should be flexible enough to be reused across customers/projects without editing its code — that's the whole point of a module. Flexibility means exposing the right variables, not exposing every possible attribute as a variable "just in case."

Use optional() attributes with defaults in object-type variables so callers only need to set what they care about.

Every variable needs a description. Every variable that can reasonably have a safe default should have one — don't force callers to specify values that rarely change.

Variables and outputs

Use type on every variable — no untyped variables.

Validate inputs with validation blocks where a bad value would fail late or unclearly otherwise (e.g. a region string, a CIDR range).

Output the values downstream modules or stages will actually need (IDs, self-links, emails) — not the entire resource object.

Mark sensitive outputs (sensitive = true) — service account keys, secrets, connection strings.

IAM and security

Follow least privilege: grant the narrowest role that accomplishes the task, scoped to the narrowest resource level (prefer project/resource-level bindings over org-level where possible).

Prefer google_*_iam_member for additive, single-principal grants used alongside other automation. Use google_*_iam_binding only when this module is meant to fully own the role's membership list. Avoid google_*_iam_policy (authoritative, replaces the whole policy) unless the module is explicitly designed to own the entire IAM policy for that resource.

Never hardcode credentials, keys, or secrets in code or .tfvars committed to the repo.

Versioning and providers

Pin provider version constraints in versions.tf (required_providers, required_version) — don't leave them unconstrained.

Pin module sources to a tag or commit SHA when referencing external modules (including this repo's own modules from other repos). Don't reference main/master directly.

Documentation

Every module needs a README.md: what it does, inputs, outputs, and a minimal usage example.

Comments explain why, not what — the code already says what a resource does; a comment should only exist for a non-obvious constraint or reason (e.g. "must be created before X due to eventual consistency").

Testing before merge

Run terraform fmt and terraform validate before opening a PR.

Run terraform plan against a real or sandbox project and review the diff — don't merge on validate passing alone.
 