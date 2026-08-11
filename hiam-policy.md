
​# IAM Terraform Modules — Design Reference

> Corrected design, matching how CFF (Cloud Foundation Fabric) actually
> builds this — not a standalone `hierarchical-iam` module sitting between
> callers and `organization`/`folder`/`project`. Each of those three
> resource-hierarchy modules owns its **own** IAM logic internally (an
> `iam.tf` topic file), using the same repeated variable shape across all
> three. This matches BESTPRACTICES.md directly: *"duplicate blocks are
> acceptable... don't introduce an abstraction just to avoid repeating a
> few lines."*
>
> Modules covered, in dependency order: **Organization → Folder → Project
> → Identities → Custom IAM Roles → IAM Deny Policy → (factory pattern for
> scale) → Workload Identity Federation (optional, deferred).**
> `hierarchical-policy` (firewall) and `hierarchical-org-policy`
> (constraints) already exist in `Finops-Project` and are out of scope here.

---

## 0. Why no standalone `hierarchical-iam` module

CFF does **not** have a separate IAM module that `organization`/`folder`/
`project` call as a dependency. Reasons, concretely:

1. **Lifecycle coupling.** A resource and its IAM bindings should be
   created/destroyed together. If IAM lived in a separate module, a
   `terraform destroy` of a project wouldn't automatically clean up its
   bindings' state — real risk of orphaned grants or a two-step apply/destroy
   order the caller has to remember.
2. **One plan, not two.** Callers should see "create this project + grant
   these roles" as a single module call and a single diff, not two module
   blocks that have to be reasoned about together.
3. **Repetition over cleverness.** CFF reuses the same **variable shape**
   (`iam`, `iam_bindings`, `iam_bindings_additive`) across all three
   resource modules, but each module has its **own** `iam.tf` implementing
   it against its own resource type
   (`google_organization_iam_member`/`_binding`,
   `google_folder_iam_member`/`_binding`, `google_project_iam_member`/`_binding`).
   Three small, near-identical files beat one shared abstraction — exactly
   BESTPRACTICES.md's stated preference.

**What does stay a separate module:** `identities` (SAs have their own
lifecycle, independent of any one project's IAM), `custom-iam-roles` (a
role definition can be reused across many projects and is versioned
independently), and `iam-deny-policy` (an exclusion mechanism, conceptually
distinct from granting).

---

## 0a. Update: standalone `iam` module (management decision — supersedes §0's default)

**Decision:** per direction from management, IAM bindings will be broken
out into their own standalone `iam` module rather than living inside
`organization`/`folder`/`project` as `iam.tf` topic files. This overrides
the CFF-matching default recommended in Section 0 — the reasoning in
Section 0 is left in place above for context/history, but the modules in
Sections 2–4 below are updated to **not** carry their own `iam.tf`
anymore; `iam.tf` is removed from `organization`, `folder`, and `project`,
and replaced by calls into this one shared `iam` module.

**What changes concretely, vs. Section 0's tradeoffs (acknowledged, not hidden):**

| Section 0 concern | How it's handled now that IAM is standalone |
|---|---|
| Lifecycle coupling (destroy order) | Caller must explicitly sequence/depend on both modules — no longer automatic. Mitigate with `depends_on = [module.projects]` on the `iam` module call, and by keying `iam`'s bindings off the resource module's own output IDs (e.g. `module.projects.project_ids["x"]`) rather than a hardcoded string, so Terraform's graph still orders them correctly. |
| One plan vs two | Now genuinely two module blocks / two diffs per change (create project, then grant IAM) — accepted tradeoff per the decision. |
| Repetition vs abstraction | This module intentionally centralizes what was three near-identical `iam.tf` files into one, parameterized by `scope` — the opposite tradeoff of BESTPRACTICES.md's stated default, taken deliberately here. |

**Module: `iam`** — one module, parameterized by `scope`
(`organization`/`folder`/`project`) and `resource_id`, covering all three
hierarchy levels instead of three separate `iam.tf` files.

```hcl
# iam/variables.tf
variable "scope" {
  description = "Which resource type this binding set targets."
  type        = string
  validation {
    condition     = contains(["organization", "folder", "project"], var.scope)
    error_message = "scope must be one of: organization, folder, project."
  }
}

variable "resource_id" {
  description = "The org ID / folder ID / project ID this module grants IAM on, matching var.scope."
  type        = string
}

variable "iam_bindings_additive" {
  description = "Additive IAM grants — default choice, safe alongside bindings made elsewhere."
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      title = string, description = optional(string, ""), expression = string
    }), null)
  }))
  default = {}
}

variable "iam" {
  description = "Authoritative role -> members map. Only set a role here if this module call should fully own that role's membership."
  type        = map(list(string))
  default     = {}
}

variable "iam_bindings" {
  description = "Authoritative, condition-aware bindings. Rare — prefer iam_bindings_additive."
  type = map(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title = string, description = optional(string, ""), expression = string
    }), null)
  }))
  default = {}
}

variable "enable_conditional_bindings" {
  description = "Master switch for IAM Conditions support. Off by default."
  type    = bool
  default = false
}
```

```hcl
# iam/main.tf
locals {
  # Picks the right resource-type-prefixed IAM resource based on scope,
  # using one dynamic block set instead of three near-duplicate files.
  is_org     = var.scope == "organization"
  is_folder  = var.scope == "folder"
  is_project = var.scope == "project"
}

resource "google_organization_iam_member" "additive" {
  for_each = local.is_org ? var.iam_bindings_additive : {}
  org_id   = var.resource_id
  role     = each.value.role
  member   = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_folder_iam_member" "additive" {
  for_each = local.is_folder ? var.iam_bindings_additive : {}
  folder   = var.resource_id
  role     = each.value.role
  member   = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_member" "additive" {
  for_each = local.is_project ? var.iam_bindings_additive : {}
  project  = var.resource_id
  role     = each.value.role
  member   = each.value.member

  dynamic "condition" {
    for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# google_organization_iam_binding / google_folder_iam_binding /
# google_project_iam_binding equivalents for var.iam and var.iam_bindings
# follow the same is_org/is_folder/is_project for_each split — omitted here
# for brevity, same pattern repeated per scope.
```

**Usage — now two module calls per binding target, one for the resource, one for its IAM:**
```hcl
module "projects" {
  source   = "../project"
  projects = { "marketing-ecommerce-prod" = { folder_id = "123", labels = {...} } }
}

module "project_iam" {
  source      = "../iam"
  scope       = "project"
  resource_id = module.projects.project_ids["marketing-ecommerce-prod"]

  iam_bindings_additive = {
    app_owner = { member = "group:marketing-app-owners@example.com", role = "roles/viewer" }
  }

  depends_on = [module.projects]
}

module "folder_iam" {
  source                = "../iam"
  scope                 = "folder"
  resource_id            = module.folders.folder_ids["Production"]
  iam_bindings_additive  = { prod_viewer = { member = "group:gcp-prod-viewers@example.com", role = "roles/viewer" } }
}

module "org_iam" {
  source                = "../iam"
  scope                 = "organization"
  resource_id            = data.google_organization.org.org_id
  iam_bindings_additive  = { org_auditor = { member = "group:auditors@example.com", role = "roles/viewer" } }
}
```

**Impact on Sections 2–4 below:** the `iam.tf` code blocks shown inside
`organization`, `folder`, and `project` in Sections 2–4 are now
**superseded** by this module — treat those inline `iam.tf` snippets as
historical/reference only. `tags.tf`/`apis.tf` topic files are unaffected
and remain inline in their respective modules (only IAM was called out by
this decision).

**Impact on the factory pattern (Section 8):** `hierarchical-iam-factory`
already called a **separate** `folder`-only module for bindings, so it's
unaffected in shape — it now targets this `iam` module (`scope = "folder"`
or `"organization"`) instead of `folder`'s old inline `iam.tf`.
`project-factory` gains one more module call per project
(`project_iam_bindings_additive` moves from a `project` input into a
loop over `iam` module calls, one per project, `scope = "project"`,
`resource_id = module.projects.project_ids[pid]`).

---

## 1. The shared IAM variable interface (used identically in all three modules)

| Variable | Terraform resource used | Ownership model | When to use |
|---|---|---|---|
| `iam_bindings_additive` | `google_*_iam_member` | Additive — safe alongside other automation/human grants; never touches bindings this module didn't create | **Default choice.** Matches BESTPRACTICES.md: *"Prefer `google_*_iam_member` for additive... use `_binding` only when this module is meant to fully own the role's membership list."* |
| `iam` | `google_*_iam_binding` (`map(list(string))`, role → members) | Authoritative per role — Terraform will remove any member not listed | Only when this module call is deliberately meant to own the full membership of a specific role |
| `iam_bindings` | `google_*_iam_binding` with IAM Condition support | Authoritative, condition-aware | Only for conditional/time-boxed authoritative grants (rare) |

```hcl
# repeated verbatim in organization/variables.tf, folder/variables.tf, project/variables.tf

variable "iam_bindings_additive" {
  description = <<-EOT
    Additive IAM grants: one member + role per entry, safe to use alongside
    bindings made by other Terraform runs or humans. This is the default —
    use this unless you specifically need to own a role's full membership.
  EOT
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, b in var.iam_bindings_additive :
      can(regex("^(group|serviceAccount|domain):", b.member)) &&
      (can(regex("^roles/", b.role)) || can(regex("^(projects|organizations|folders)/[^/]+/roles/", b.role)))
    ])
    error_message = "iam_bindings_additive members must be group:/serviceAccount:/domain: (never user:) and roles must be predefined (roles/...) or a custom role ID."
  }
}

variable "iam" {
  description = "Authoritative role -> members map. Only set a role here if this module call should fully own that role's membership (removes anything not listed)."
  type        = map(list(string))
  default     = {}
}

variable "iam_bindings" {
  description = "Authoritative, condition-aware bindings. Rare — prefer iam_bindings_additive unless a time-boxed authoritative grant is genuinely required."
  type = map(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}
```

Each module's `iam.tf` renders these against its own resource type — shown
per module below.

---

## 1a. Gate-flag convention (`enable_*` / `create_*`) used across these modules

Per BESTPRACTICES.md's boolean-prefix rule, every **optional** capability
across these modules is off by default and switched on explicitly — this
is what keeps the modules generic/reusable without editing their code for
every caller.

| Flag | Lives in | Default | What it unlocks when true |
|---|---|---|---|
| `enable_conditional_bindings` | `organization`, `folder`, `project` | `false` | Renders the `dynamic "condition"` block on any `iam_bindings_additive`/`iam_bindings` entry that sets a `condition` — time-boxed/break-glass grants (e.g. temporary Production `roles/editor`). When `false`, any `condition` set on an entry is ignored and the grant applies unconditionally, keeping the common case's `plan` output clean. |
| `enable_audit_config` | `project` | `false` | Adds a Data Access audit-log config (`google_project_iam_audit_config`) for that project — turn on for PHI/Production, leave off elsewhere to avoid unnecessary log volume/cost. |
| `create_service_account` | `identities` (per-entry, not module-wide) | n/a — every map entry always creates one | Not actually a gate today; kept here as a callout: if a future need arises for "reference an existing SA instead of creating one" (mirroring `Finops-Project/finops-function`'s own `create_service_account` toggle), add a per-entry `create = optional(bool, true)` field to `service_accounts`, following this same convention — don't add it speculatively before that need appears. |
| `disable_on_destroy` | `project` (`apis.tf`) | `false` (hardcoded, matches `Finops-Project/project/main.tf`'s existing default) | Not caller-exposed today — APIs stay enabled even if the project's Terraform config is destroyed, avoiding accidental service disruption. Could become a variable if a real case needs the opposite, following the same pattern. |

**Why gate instead of always-on:** most callers (a plain group→role grant,
a project with no special audit requirement) never need Conditions or
audit configs — forcing every module call to reason about them would
violate BESTPRACTICES.md's *"flexibility from well-designed variables, not
from exposing every attribute."* Gating keeps the common case a two-line
binding entry, and the advanced case opts in explicitly, with the gate
name self-documenting *why* the extra resource appears in `terraform plan`.

**Rule going forward:** any new optional capability added to these modules
follows the same pattern — new resource behavior behind a boolean gate,
default `false`, never a breaking change to existing callers.

```hcl
# added to organization/variables.tf, folder/variables.tf, project/variables.tf
variable "enable_conditional_bindings" {
  description = "Master switch for IAM Conditions support on iam_bindings_additive/iam_bindings entries. Off by default — keeps the common unconditional case free of extra plan noise."
  type    = bool
  default = false
}
```

```hcl
# added to project/variables.tf only
variable "enable_audit_config" {
  description = "When true, adds a Data Access audit-log config for this project. Off by default — turn on deliberately for PHI/Production."
  type    = bool
  default = false
}
```

```hcl
# project/audit.tf — only rendered when enable_audit_config = true
resource "google_project_iam_audit_config" "this" {
  count = var.enable_audit_config ? 1 : 0

  project = "PLACEHOLDER" # one per project needing it — see note below
  service = "allServices"

  audit_log_config {
    log_type = "DATA_READ"
  }
}
```

> Note: since `project` now manages *multiple* projects via `for_each`,
> `enable_audit_config` as a single module-wide bool applies the same
> choice to every project in that module call. If different projects in
> the same call need different audit settings, move `enable_audit_config`
> to be a **per-project field** inside the `projects` map object instead
> (`audit_config_enabled = optional(bool, false)`) — don't keep it
> module-wide once that mixed case actually appears.

And correspondingly, every `dynamic "condition"` block shown in Sections
2–4's `iam.tf` files should be gated:

```hcl
dynamic "condition" {
  for_each = var.enable_conditional_bindings && each.value.condition != null ? [each.value.condition] : []
  content {
    title       = condition.value.title
    description = condition.value.description
    expression  = condition.value.expression
  }
}
```

(The `iam.tf` snippets in Sections 2–4 above should be read with this gate
applied — shown unabridged here once rather than repeated three times.)

---

## 2. `organization` module

**Responsibility:** represents the existing GCP Organization (data-only, no
`google_organization` resource — orgs aren't created by Terraform) and owns
org-level IAM (actual Org Policy resources stay in the existing
`hierarchical-org-policy` module).

```hcl
# organization/main.tf
data "google_organization" "org" {
  organization = var.org_id
}
```

> **`iam.tf` removed here per Section 0a.** Org-level IAM bindings are no
> longer implemented inside this module — use the standalone `iam` module
> (`scope = "organization"`) instead. The `google_organization_iam_member`/
> `_binding` resources previously shown in this section now live there.

```hcl
# organization/variables.tf
variable "org_id" {
  description = "GCP Organization ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "org_id must be a numeric GCP Organization ID."
  }
}

variable "tags" {
  description = <<-EOT
    Org-level metadata via Resource Manager Tags — NOT `labels`. GCP does
    not support a `labels` field on `google_organization` the way it does
    on `google_project`; Tags are the equivalent mechanism here. Flat map:
    key = tag key short name (e.g. "business-unit"), value = tag value
    short name (e.g. "businesssvc"). Tag keys/values must already exist
    (created once, referenced everywhere) — see `tags.tf` below.
  EOT
  type    = map(string)
  default = {}
}
# iam_bindings_additive / iam / iam_bindings REMOVED per Section 0a —
# organization-level IAM now goes through the standalone `iam` module.
```

```hcl
# organization/tags.tf
# Applies pre-existing tag key/value pairs to the Org resource itself.
# Tag keys/values are typically created once, org-wide, in a dedicated
# `tags` module — this module only binds them, it doesn't create them.

resource "google_tags_tag_binding" "org_tags" {
  for_each = var.tags

  parent    = "//cloudresourcemanager.googleapis.com/organizations/${var.org_id}"
  tag_value = "tagValues/${each.value}" # resolved tag_value ID, e.g. from a `tags` module's output
}
```

**Usage:**
```hcl
module "org" {
  source = "../organization"
  org_id = "123456789012"

  tags = {
    business-unit = module.tags.tag_value_ids["business-unit/businesssvc"]
  }
}

module "org_iam" {
  source      = "../iam"
  scope       = "organization"
  resource_id = module.org.org_id # or data.google_organization.org.org_id

  iam_bindings_additive = {
    org_admin = {
      member = "group:gcp-organization-admins@example.com"
      role   = "roles/resourcemanager.organizationAdmin"
    }
    security_reviewer = {
      member = "group:gcp-security-reviewers@example.com"
      role   = "roles/iam.securityReviewer"
    }
  }
}
```

---

## 3. `folder` module

**Responsibility:** creates the 8 folders (Common, Production, NonProduction,
PHI, Research, Isolated, Decommissioned, Network) under the Org, each with
its own folder-level IAM. One `for_each` over a flat map of folder configs —
no nested loops.

```hcl
# folder/variables.tf
variable "folders" {
  description = "Flat map of folders to create: key = folder display name, value = its config."
  type = map(object({
    parent = string # "organizations/<org_id>" or "folders/<parent_folder_id>"
    tags   = optional(map(string), {}) # Resource Manager Tags — folders have no `labels` field, same as organization
  }))
}

variable "folder_iam_bindings_additive" {
  description = "REMOVED per Section 0a — folder-level IAM now goes through the standalone `iam` module (scope = \"folder\"), not through this variable."
  type    = map(map(object({
    member = string
    role   = string
    condition = optional(object({
      title = string, description = optional(string, ""), expression = string
    }), null)
  })))
  default = {}
}
```
> Note: `folder_iam_bindings_additive` is kept above only as a marker of
> what used to exist here — remove it entirely once callers have migrated
> to the standalone `iam` module. Do not wire it to any resource in this
> module anymore.

```hcl
# folder/main.tf
resource "google_folder" "this" {
  for_each = var.folders

  display_name = each.key
  parent       = each.value.parent
}
```

```hcl
# folder/tags.tf
locals {
  folder_tags_flat = merge([
    for folder_name, tags in { for k, v in var.folders : k => v.tags } : {
      for tag_key, tag_value in tags : "${folder_name}::${tag_key}" => {
        folder_name = folder_name
        tag_value   = tag_value
      }
    }
  ]...)
}

resource "google_tags_tag_binding" "folder_tags" {
  for_each = local.folder_tags_flat

  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.this[each.value.folder_name].name}"
  tag_value = "tagValues/${each.value.tag_value}"
}
```

```hcl
# folder/iam.tf
# REMOVED per Section 0a — folder-level IAM bindings now go through the
# standalone `iam` module (scope = "folder", resource_id =
# google_folder.this[<name>].id), not implemented inside this module.
```

> Note: this flatten-two-levels pattern (`merge([for ... : { for ... }])`)
> was previously used here for `folder_iam_bindings_additive` before IAM was
> pulled into the standalone `iam` module (Section 0a). It's kept as
> documented precedent — the same pattern still applies inside `identities`
> and the `iam` module itself wherever a caller supplies one map per
> scope-instance. If it gets unwieldy, prefer the factory pattern (Section 8)
> with one YAML file per instance instead of a nested map literal.

**Usage:**
```hcl
module "folders" {
  source = "../folder"

  folders = {
    Common = {
      parent = "organizations/123456789012"
    }
    Production = {
      parent = "organizations/123456789012"
      tags   = { environment = module.tags.tag_value_ids["environment/production"] }
    }
    NonProduction  = { parent = "organizations/123456789012" }
    PHI            = { parent = "organizations/123456789012" }
    Research       = { parent = "organizations/123456789012" }
    Isolated       = { parent = "organizations/123456789012" }
    Decommissioned = { parent = "organizations/123456789012" }
    Network        = { parent = "organizations/123456789012" }
  }
}

module "folder_iam" {
  source = "../iam"
  for_each = {
    Production = {
      prod_viewer = {
        member = "group:gcp-prod-viewers@example.com"
        role   = "roles/viewer"
      }
    }
    PHI = {
      compliance_viewer = {
        member = "group:gcp-compliance-viewers@example.com"
        role   = "roles/viewer"
      }
    }
    # Common, Isolated intentionally have no entry — no folder-wide grant by design
  }

  scope                 = "folder"
  resource_id            = module.folders.folder_ids[each.key]
  iam_bindings_additive  = each.value

  depends_on = [module.folders]
}
```

> Since `iam` is scoped to one `resource_id` per call, granting bindings on
> multiple folders now means one `iam` module instance **per folder**
> (`for_each` over the folder-keyed bindings map, shown above) rather than
> the single nested-map call `folder_iam_bindings_additive` used to allow.
> This is the concrete cost of Section 0a's "two diffs, not one" tradeoff.

> **Labels vs. Tags — why the split:** GCP `labels` (simple key:value strings)
> only exist on `google_project` and resource-level objects (VMs, buckets).
> `google_organization`/`google_folder` have no `labels` field at all —
> Resource Manager **Tags** (`google_tags_tag_key`/`tag_value` +
> `google_tags_tag_binding`) are the equivalent mechanism at Org/Folder
> scope, and are also usable as **Conditional IAM/Org Policy** targeting
> (something plain labels can't do) — e.g. "this Org Policy applies only to
> resources tagged `environment:production`". Keep a small, separate `tags`
> module that creates the tag keys/values once or​g-wide (`business-unit`,
> `environment`, `cost-center`); `organization`/`folder`/`project` modules
> only *bind* pre-created tag values, they don't create them.

---

## 4. `project` module

**Responsibility:** creates one or more `google_project` resources with
labels, folder placement, and their own project-level IAM — same
`iam_bindings_additive`/`iam`/`iam_bindings` shape as Sections 2–3, this
time rendered against `google_project_iam_member`/`_binding`.

```hcl
# project/variables.tf
variable "projects" {
  description = <<-EOT
    Flat map of projects to create: key = project_id, value = its config.
    Mandatory labels: team, environment, cost_center, app, owner, location.
  EOT
  type = map(object({
    folder_id     = string
    activate_apis = optional(list(string), []) # APIs enabled on THIS project only — see Section 4a
    labels = object({
      team        = string
      environment = string
      cost_center = string
      app         = string
      owner       = string
      location    = string
    })
  }))

  validation {
    condition = alltrue([
      for pid, p in var.projects :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", pid))
    ])
    error_message = "Every project_id key must be a valid GCP project ID (6-30 chars, lowercase, digits, hyphens)."
  }
}

variable "project_iam_bindings_additive" {
  description = "REMOVED per Section 0a — project-level IAM now goes through the standalone `iam` module (scope = \"project\"), not through this variable."
  type = map(map(object({
    member = string
    role   = string
    condition = optional(object({
      title = string, description = optional(string, ""), expression = string
    }), null)
  })))
  default = {}
}
```
> Note: kept above only as a marker of what used to live here — remove
> entirely once callers migrate to the standalone `iam` module.

```hcl
# project/main.tf
resource "google_project" "this" {
  for_each = var.projects

  project_id = each.key
  name       = each.key
  folder_id  = each.value.folder_id
  labels     = each.value.labels
}
```

```hcl
# project/apis.tf
locals {
  project_apis_flat = merge([
    for project_id, p in var.projects : {
      for api in p.activate_apis : "${project_id}::${api}" => { project_id = project_id, api = api }
    }
  ]...)
}

resource "google_project_service" "apis" {
  for_each = local.project_apis_flat

  project            = google_project.this[each.value.project_id].project_id
  service            = each.value.api
  disable_on_destroy = false
}
```

```hcl
# project/iam.tf
# REMOVED per Section 0a — project-level IAM bindings now go through the
# standalone `iam` module (scope = "project", resource_id =
# google_project.this[<project_id>].project_id), not implemented here.
```

### 4a. Why API enablement is clubbed into `project`, not a separate module

Applying the same two-question test from
`module-boundaries-clubbing-vs-separate.md`:

1. **Lifecycle-bound to one project?** Yes — enabled APIs only matter while
   that project exists; there's no reason for `google_project_service` to
   outlive the project it's enabled on.
2. **Same reviewer as the project itself?** Yes — deciding which APIs a
   project needs (Cloud Functions API, Secret Manager API, etc.) is a
   normal part of provisioning that project, made by the same team that
   requests the project, not a separate governance decision.

Both are "yes," so this stays a topic file (`apis.tf`) inside `project`,
exactly like `iam.tf` and `tags.tf` — matching the existing precedent
already in `Finops-Project/project/main.tf` (`google_project_service.apis`,
gated by `var.activate_apis`), just generalized to the multi-project `for_each`
shape used everywhere else in this design.

**Usage:**
```hcl
module "projects" {
  source = "../project"

  projects = {
    "marketing-ecommerce-prod" = {
      folder_id     = module.folders.folder_ids["Production"]
      activate_apis = ["cloudfunctions.googleapis.com", "secretmanager.googleapis.com"]
      labels = {
        team = "marketing", environment = "prod", cost_center = "12345"
        app = "ecommerce", owner = "john.doe", location = "us"
      }
    }
  }
}

module "project_iam" {
  source      = "../iam"
  scope       = "project"
  resource_id = module.projects.project_ids["marketing-ecommerce-prod"]

  iam_bindings_additive = {
    app_owner = {
      member = "group:marketing-app-owners@example.com"
      role   = "roles/viewer"
    }
  }

  depends_on = [module.projects]
}
```

---

## 5. `identities` module (Service Accounts)

**Responsibility:** create Service Accounts and grant **their own**
project/resource-scoped roles. Stays a **separate** module — an SA's
lifecycle isn't tied to one project's IAM the way a group grant is; SAs get
referenced by other modules (WIF, Cloud Functions, GKE workloads) after
creation, so they need stable, independent outputs.

> **Correction from earlier in this doc:** SAs were previously judged
> "won't scale past a hand-written map" by comparing SA *count* to
> *project* count directly. That comparison was wrong. The real driver is
> **SA count = project count × workload types per project** (a runtime SA
> per Cloud Function, per GKE workload, per Cloud Run job, per CI/CD
> deployer, etc.) — which is a strict *multiple* of project count, not
> less than it. Applying the same 3-question factory test from earlier
> (many instances? non-Terraform-comfortable editor? uniform shape?) —
> once a project regularly needs 2–4+ SAs each, this passes all three just
> like `project` does. **`identities` gets a factory too, `identities-factory`,
> mirroring `project-factory`.**

```hcl
# identities/variables.tf
variable "service_accounts" {
  description = "Flat map of Service Accounts to create: key = account_id, value = its config."
  type = map(object({
    project_id   = string
    display_name = string
    roles        = list(string) # roles granted to this SA, in its own project
  }))
}
```

```hcl
# identities/main.tf
resource "google_service_account" "sa" {
  for_each = var.service_accounts

  project      = each.value.project_id
  account_id   = each.key
  display_name = each.value.display_name
}
```

```hcl
# identities/iam.tf
locals {
  sa_role_grants = merge([
    for sa_key, sa in var.service_accounts : {
      for role in sa.roles : "${sa_key}::${role}" => { sa_key = sa_key, role = role, project_id = sa.project_id }
    }
  ]...)
}

resource "google_project_iam_member" "sa_roles" {
  for_each = local.sa_role_grants

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_key].email}"
}

output "emails" {
  description = "Map of account_id -> SA email, for other modules to reference"
  value       = { for k, v in google_service_account.sa : k => v.email }
}
```

**Usage (hand-written — fine below a few dozen SAs, same as `project` before its factory):**
```hcl
module "identities" {
  source = "../identities"

  service_accounts = {
    "wl-ecommerce-sa" = {
      project_id   = "marketing-ecommerce-prod"
      display_name = "Runtime SA for ecommerce workload"
      roles        = ["roles/logging.logWriter", "roles/secretmanager.secretAccessor"]
    }
  }
}
```

The one exception noted earlier still holds unchanged: a bootstrap/deployer
SA needing folder/org-scope grants is handled by also passing that SA's
`serviceAccount:` member into `folder`'s or `organization`'s
`iam_bindings_additive` directly — no special-casing inside `identities`.
See **Section 8** for the `identities-factory` that replaces this
hand-written map once SA count grows past a few dozen.

---

## 6. `custom-iam-roles` module

**Responsibility:** create custom role *definitions* only — a separate
module (different resource type/lifecycle from granting, reusable across
many projects).

```hcl
# custom-iam-roles/variables.tf
variable "scope" {
  description = "Where the custom role is defined: organization or project"
  type        = string
  validation {
    condition     = contains(["organization", "project"], var.scope)
    error_message = "scope must be 'organization' or 'project' (custom roles cannot be defined at folder scope)."
  }
}

variable "org_id" {
  type    = string
  default = ""
}

variable "project_id" {
  type    = string
  default = ""
}

variable "custom_roles" {
  description = "Flat list of custom role definitions. Only add an entry after confirming no predefined role fits — document why in `reason`."
  type = list(object({
    role_id     = string
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
    reason      = string
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.custom_roles : length(r.permissions) > 0 && length(r.reason) > 0])
    error_message = "Each custom role must list at least one permission and a non-empty 'reason'."
  }
}
```

```hcl
# custom-iam-roles/main.tf
locals {
  roles_by_key = { for r in var.custom_roles : r.role_id => r }
}

resource "google_organization_iam_custom_role" "role" {
  for_each = var.scope == "organization" ? local.roles_by_key : {}

  org_id      = var.org_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

resource "google_project_iam_custom_role" "role" {
  for_each = var.scope == "project" ? local.roles_by_key : {}

  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

output "custom_role_ids" {
  description = "Fully-qualified custom role IDs, ready to reference in any module's iam_bindings_additive.role"
  value = merge(
    { for k, v in google_organization_iam_custom_role.role : k => v.id },
    { for k, v in google_project_iam_custom_role.role : k => v.id },
  )
}
```

**Usage — hands off directly into `project`'s `iam_bindings_additive`:**
```hcl
module "custom_roles" {
  source     = "../custom-iam-roles"
  scope      = "project"
  project_id = "marketing-ecommerce-prod"

  custom_roles = [{
    role_id     = "customSecretReaderNoList"
    title       = "Secret Reader (no list)"
    permissions = ["secretmanager.versions.access"]
    reason      = "secretAccessor also grants list; this workload must not enumerate secret names."
  }]
}

module "projects" {
  source = "../project"
  # ...
}

module "project_iam" {
  source      = "../iam"
  scope       = "project"
  resource_id = module.projects.project_ids["marketing-ecommerce-prod"]

  iam_bindings_additive = {
    restricted_secret_read = {
      member = "serviceAccount:${module.identities.emails["wl-ecommerce-sa"]}"
      role   = module.custom_roles.custom_role_ids["customSecretReaderNoList"]
    }
  }

  depends_on = [module.projects]
}
```

---

## 7. `iam-deny-policy` module

**Responsibility:** the only real "exception" mechanism — IAM Allow
policies (everything in Sections 2–5) are purely additive and cannot
subtract a higher-level grant. `google_iam_deny_policy` is what expresses
"this principal/role is explicitly blocked here, even though a broader
grant above would otherwise allow it." Build this **only when a real case
appears** (e.g. Isolated folder needs to guarantee no principal outside a
short allow-list can ever act, regardless of any accidental broader grant)
— not speculatively.

```hcl
# iam-deny-policy/variables.tf
variable "scope" {
  description = "Where the deny policy attaches: organizations, folders, or projects"
  type        = string
  validation {
    condition     = contains(["organizations", "folders", "projects"], var.scope)
    error_message = "scope must be 'organizations', 'folders', or 'projects'."
  }
}

variable "target_id" {
  description = "The org/folder/project ID the deny policy attaches to"
  type        = string
}

variable "policy_name" {
  description = <<-EOT
    Unique name for this deny policy resource, scoped to (scope, target_id).
    REQUIRED to be unique per team/purpose — google_iam_deny_policy is
    authoritative for its own (parent, name) pair, so two different teams
    calling this module against the SAME target_id must use DIFFERENT
    policy_name values (e.g. "networking-guardrails",
    "external-access-guardrails") or they will silently overwrite each
    other's rules. One team reusing the same policy_name across multiple
    calls will instead correctly update their own single policy.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,61}$", var.policy_name))
    error_message = "policy_name must be lowercase alphanumeric/dash, 3-62 chars."
  }
}

variable "deny_rules" {
  description = "Flat list of deny rules: denied permissions/roles for a set of principals, with optional exceptions."
  type = list(object({
    denied_principals  = list(string) # e.g. ["principalSet://goog/public:all"]
    denied_permissions = list(string) # e.g. ["iam.googleapis.com/roles.create"]
    exception_principals = optional(list(string), []) # explicitly exempted principals
    reason             = string
  }))

  validation {
    condition     = alltrue([for r in var.deny_rules : length(r.reason) > 0])
    error_message = "Each deny rule must document a 'reason'."
  }
}
```

```hcl
# iam-deny-policy/main.tf
resource "google_iam_deny_policy" "this" {
  parent       = "${var.scope}/${var.target_id}"
  name         = "deny-${var.policy_name}"
  display_name = "Deny policy: ${var.policy_name} (${var.target_id})"

  rules {
    dynamic "deny_rule" {
      for_each = var.deny_rules
      content {
        denied_principals    = deny_rule.value.denied_principals
        denied_permissions   = deny_rule.value.denied_permissions
        exception_principals = deny_rule.value.exception_principals
      }
    }
  }
}
```

### Multi-team ownership — read this before calling the module

`google_iam_deny_policy` is **authoritative per (parent, name)** — unlike
IAM Allow bindings (`google_*_iam_member`), which are additive and safe for
many independent Terraform runs to touch the same project, a deny policy
resource is the *entire* rule document for that name. Two different teams
independently calling this module against the **same** `target_id` **must**
pass **different `policy_name` values** (e.g.
`policy_name = "networking-guardrails"` for the network team,
`policy_name = "phi-access-guardrails"` for the compliance team on the same
`PHI` folder). If they instead both use the same `policy_name`, whichever
`apply` runs last silently overwrites the other's rules — there is no
merge. Google Cloud does support multiple independently-named deny
policies attached to the same parent, so this is the supported pattern for
"different teams, same scope" — not a workaround.

If a single team wants to *add* a rule to their own existing policy, they
call the module again with the **same** `policy_name` and the **full**
updated `deny_rules` list (including prior rules) — because the list is
authoritative, a shorter list on a later call will *remove* the rules that
were dropped, not just leave them alone.

**Usage — e.g. Isolated folder, guaranteeing no external identity can ever
be granted access even by mistake:**
```hcl
module "isolated_folder_deny" {
  source      = "../iam-deny-policy"
  scope       = "folders"
  target_id   = module.folders.folder_ids["Isolated"]
  policy_name = "isolated-external-access-guardrails"

  deny_rules = [{
    denied_principals  = ["principalSet://goog/public:all"]
    denied_permissions = ["*"]
    exception_principals = [
      "principal://goog/subject/isolated-workload-sa@isolated-project.iam.gserviceaccount.com"
    ]
    reason = "Isolated folder must never be reachable by any principal except its own dedicated workload SA, regardless of any accidental broader IAM grant."
  }]
}

# A DIFFERENT team, same folder, different policy_name — safe, independent resource:
module "isolated_folder_network_deny" {
  source      = "../iam-deny-policy"
  scope       = "folders"
  target_id   = module.folders.folder_ids["Isolated"]
  policy_name = "isolated-networking-guardrails"   # different name = different resource, no collision

  deny_rules = [{
    denied_principals  = ["principalSet://goog/public:all"]
    denied_permissions = ["compute.googleapis.com/firewalls.create"]
    reason = "Network team's own guardrail — independent of the access guardrail above."
  }]
}
```

### 7a. No resource-level scope — a real GCP limitation, not a design gap

`var.scope` is intentionally restricted to
`["organizations", "folders", "projects"]` — this is **not** a
self-imposed limitation, it reflects `google_iam_deny_policy` itself:
**GCP does not support attaching a Deny Policy to an individual resource**
(one Secret Manager secret, one BigQuery dataset, one Storage bucket).
Deny Policy can only attach at Organization, Folder, or Project scope.

If a real requirement shows up for "deny this principal from touching
*this one specific secret*, regardless of any broader Allow grant," there
is no Deny Policy that can express it. Use one of these instead, in order
of preference:

1. **Tighten the Allow grant itself (preferred).** Don't grant broadly at
   project scope if a resource needs stricter access — grant the narrower
   Allow binding directly on that one resource (e.g.
   `google_secret_manager_secret_iam_member` scoped to just that secret
   ID) so nothing broad exists to conflict with in the first place.
2. **Use an IAM Condition on the resource-level Allow binding.** Add a
   `condition` block (already supported via this design's
   `iam_bindings_additive.condition` field) directly to a resource-level
   Allow binding — e.g. a project-wide `roles/secretmanager.secretAccessor`
   grant with `condition.expression =
   "resource.name.startsWith('projects/x/secrets/allowed-secret')"` narrows
   what that grant actually covers. This is the closest real substitute for
   "deny at resource level."
3. **Fall back to a Project-scoped Deny with a narrow `denied_permissions`
   list.** Deny Policy can target specific IAM permissions (e.g.
   `secretmanager.versions.access`) at Project scope — project-wide in
   reach, but permission-specific in what it blocks. Sometimes narrow
   enough to be the practical answer even though it can't pin to one exact
   resource ID.

---

## 8. Scaling to hundreds of projects/folders — the factory pattern

Hand-writing one `projects = { ... }` map entry (or `folders = { ... }`)
per project/folder in `.tf` code doesn't scale past a few dozen. CFF's
answer: **one YAML file per project, one generic `for_each` reads all of
them** — no `.tf` changes needed to onboard a new project.

### When does *any* module earn a factory? (general rule, not project-specific)

This isn't unique to `project` or `identities` — apply the same 3-question
test (introduced earlier for `identities`) to **any** module in this doc
before deciding to add a factory for it:

1. **Many near-identical instances?** (dozens+, growing over time, not a
   fixed small set)
2. **Does someone non-Terraform-comfortable need to edit it?** (an app
   team member adding their own entry, not a Terraform engineer)
3. **Is the data uniform in shape?** (same fields every time — a template
   fits, not bespoke per-entry logic)

All three "yes" → build a factory (`<module>-factory`, one YAML per
instance, generic `for_each` reads the directory). Any "no" → stay a
hand-written map/list literal, permanently, not as a stopgap.

Applied across every module in this doc:

| Module | Many instances? | Non-TF editor? | Uniform shape? | Factory? |
|---|---|---|---|---|
| `project` | Yes (team×app×env) | Yes (app teams) | Yes | **Yes — `project-factory`** |
| `identities` | Yes (projects × workload types) | Yes (app/workload teams) | Yes | **Yes — `identities-factory`** |
| `folder` | No (fixed ~8, org-wide) | No (Security/DevOps only) | N/A | No — literal map stays |
| `organization` | No (exactly 1) | No | N/A | No |
| `custom-iam-roles` | No (rare, deliberate) | No (Security/DevOps) | N/A | No |
| `iam-deny-policy` | No (should stay rare by design — see Section 7) | No (Security/DevOps) | N/A | No |

**Rule going forward:** don't build a factory for a module preemptively —
build the plain map/list module first (as every module in Sections 2–7
does), and only graduate it to a `<module>-factory` once real usage
crosses this 3-question threshold, exactly as happened here for both
`project` and `identities`.

### Two factories, matching two different review tiers

| Factory | Scope | Contains | Reviewer |
|---|---|---|---|
| **`project-factory`** | Project | Project attributes **and** its own project-level IAM, combined in one YAML per project | App team + light DevOps review |
| **`identities-factory`** | Service Account | One SA (project, display name, roles) per YAML | Owning app/workload team |
| **`hierarchical-iam-factory`** | Folder / Org | Only folder/org-level bindings — not owned by any single project | Security / DevOps only |

```yaml
# factories/projects/marketing-ecommerce-prod.yaml
project_id: marketing-ecommerce-prod
folder_id: "987654321"
activate_apis:               # APIs live under project-factory too — see Section 4a
  - cloudfunctions.googleapis.com
  - secretmanager.googleapis.com
labels:
  team: marketing
  environment: prod
  cost_center: "12345"
  app: ecommerce
  owner: john.doe
  location: us

iam_bindings_additive:
  app_owner:
    member: "group:marketing-app-owners@example.com"
    role: "roles/viewer"
```

```hcl
# project-factory/main.tf
locals {
  project_files = fileset("${path.module}/factories/projects", "*.yaml")
  projects_data = {
    for f in local.project_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/projects/${f}"))
  }
}

module "projects" {
  source = "../project"

  projects = {
    for pid, p in local.projects_data : pid => {
      folder_id     = p.folder_id
      activate_apis = try(p.activate_apis, [])
      labels        = p.labels
    }
  }
}

module "project_iam" {
  source   = "../iam"
  for_each = local.projects_data

  scope                  = "project"
  resource_id            = module.projects.project_ids[each.key]
  iam_bindings_additive  = each.value.iam_bindings_additive

  depends_on = [module.projects]
}
```

```yaml
# factories/hierarchical-iam/production-folder.yaml
folder_name: Production
bindings:
  prod_viewer:
    member: "group:gcp-prod-viewers@example.com"
    role: "roles/viewer"
```

```hcl
# hierarchical-iam-factory/main.tf
locals {
  hier_iam_files = fileset("${path.module}/factories/hierarchical-iam", "*.yaml")
  hier_iam_data = {
    for f in local.hier_iam_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/hierarchical-iam/${f}"))
  }
}

module "folders" {
  source  = "../folder"
  folders = var.folders # from Section 3
}

module "folder_iam" {
  source   = "../iam"
  for_each = { for k, v in local.hier_iam_data : v.folder_name => v.bindings }

  scope                 = "folder"
  resource_id            = module.folders.folder_ids[each.key]
  iam_bindings_additive  = each.value

  depends_on = [module.folders]
}
```

### Why this needs no changes to any module above

Every module in Sections 2–6 already takes flat map/list variables — that's
exactly what makes them factory-compatible without modification. The
factory only changes **how** those variables get populated (YAML +
`for_each`, instead of a hand-written literal).

### `identities-factory` — one YAML per Service Account

Same shape as `project-factory`, applied to `identities` (Section 5): once
SA count = projects × workload-types-per-project grows past a few dozen
hand-written map entries, switch to one YAML file per SA, owned by
whichever team owns that workload (app team for a runtime SA, DevOps for a
CI/CD deployer SA) — reviewed by that same team, matching who'd write the
literal map entry today.

```yaml
# factories/identities/wl-ecommerce-sa.yaml
project_id: marketing-ecommerce-prod
display_name: "Runtime SA for ecommerce workload"
roles:
  - roles/logging.logWriter
  - roles/secretmanager.secretAccessor
```

```hcl
# identities-factory/main.tf
locals {
  sa_files = fileset("${path.module}/factories/identities", "*.yaml")
  sa_data = {
    for f in local.sa_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/factories/identities/${f}"))
  }
}

module "identities" {
  source           = "../identities"
  service_accounts = local.sa_data
}
```

No changes needed to `identities` itself — same reasoning as `project`:
it already takes a flat map, so the factory only changes how that map is
populated (one YAML per SA vs. a hand-written literal).

### Optional: shared defaults across hundreds of project files

```hcl
locals {
  defaults = yamldecode(file("${path.module}/factories/projects/_defaults.yaml"))
  projects_data = {
    for f in local.project_files :
    trimsuffix(f, ".yaml") => merge(local.defaults, yamldecode(file("${path.module}/factories/projects/${f}")))
    if f != "_defaults.yaml"
  }
}
```

Add this only once a real repeated binding appears across many files — not
speculatively.

---

## 9. Workload Identity Federation (optional, deferred)

**Responsibility:** lets CI/CD (env0, GitHub Actions) authenticate as a
deployer/workload SA without a static key. Separate module — one-time,
mostly-static setup (pool/provider), distinct lifecycle from ongoing IAM
grants. **Build this last, only when the pipeline is actually ready to move
off human impersonation** (today's local/human `user_token_creator`
impersonation, already working, is a legitimate interim state — see prior
discussion).

```hcl
# workload-identity-federation/variables.tf
variable "project_id" {
  description = "Project hosting the WIF pool"
  type        = string
}

variable "pool_id" {
  type    = string
  default = "cicd-pool"
}

variable "providers" {
  description = <<-EOT
    Flat map of WIF providers to create, one per CI/CD system (env0, GitHub
    Actions, etc). Key = provider_id.
  EOT
  type = map(object({
    issuer_uri          = string # e.g. "https://token.actions.githubusercontent.com" or env0's OIDC issuer
    attribute_mapping   = map(string)
    attribute_condition = optional(string, null)
  }))
}

variable "sa_bindings" {
  description = "Flat list: which SA each provider's principal(s) may impersonate."
  type = list(object({
    sa_email          = string
    provider_id       = string
    repo_or_workspace = string # e.g. "your-org/Finops-Project" or env0 project/workspace ID
  }))
}
```

```hcl
# workload-identity-federation/main.tf
resource "google_iam_workload_identity_pool" "cicd" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  for_each = var.providers

  project                             = var.project_id
  workload_identity_pool_id           = google_iam_workload_identity_pool.cicd.workload_identity_pool_id
  workload_identity_pool_provider_id  = each.key

  attribute_mapping   = each.value.attribute_mapping
  attribute_condition = each.value.attribute_condition

  oidc { issuer_uri = each.value.issuer_uri }
}

resource "google_service_account_iam_member" "wif_binding" {
  for_each = { for b in var.sa_bindings : "${b.sa_email}::${b.provider_id}" => b }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.sa_email}"
  role                = "roles/iam.workloadIdentityUser"
  member              = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.cicd.name}/attribute.repository/${each.value.repo_or_workspace}"
}
```

**Notes for later, when this gets built:**
- Exact issuer URL/claims for **env0** specifically need checking against
  env0's own OIDC documentation before filling in `issuer_uri`/
  `attribute_mapping` — not assumed here.
- Once built, this replaces the human `user_token_creator` binding used
  today for the deployer SA — but only for CI/CD-triggered runs; local
  developer runs can keep human impersonation as a fallback.

---

## 10. Build order (dependency-respecting)

1. `organization` (Section 2) — data source only, no IAM inside it anymore
   (Section 0a).
2. `folder` (Section 3) — depends on org_id from step 1.
3. `project` (Section 4) — depends on folder_ids from step 2.
4. `iam` (Section 0a) — standalone module, built alongside/right after
   step 3; called separately per scope (`organization`/`folder`/`project`)
   once each hierarchy-level module's resource IDs exist to reference.
5. `identities` (Section 5) — depends on project_ids from step 3.
6. `custom-iam-roles` (Section 6) — independent, but typically referenced
   by step 4's `iam_bindings_additive.role`.
7. `iam-deny-policy` (Section 7) — build only when a real exception case
   appears.
8. `project-factory` + `hierarchical-iam-factory` (Section 8) — once
   modules 1–5 are stable and project count starts exceeding what's
   comfortable to hand-write. Both factories now also call `iam` per
   instance, per Section 0a's updated factory snippets.
9. `workload-identity-federation` (Section 9) — deferred until the CI/CD
   pipeline (env0) is ready to move off human impersonation.

For each module: standard file layout (`main.tf`/`variables.tf`/
`outputs.tf`/`versions.tf`/`README.md`), `examples/basic/`, `terraform fmt`
+ `validate` + a real `plan` against a sandbox project before merge — per
`agents.md`'s checklist.
