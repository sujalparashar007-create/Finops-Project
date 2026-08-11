
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

```hcl
# organization/iam.tf
resource "google_organization_iam_member" "additive" {
  for_each = var.iam_bindings_additive

  org_id = var.org_id
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_organization_iam_binding" "authoritative" {
  for_each = var.iam

  org_id  = var.org_id
  role    = each.key
  members = each.value
}
```

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
# ...iam_bindings_additive / iam / iam_bindings as in Section 1
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
  description = "Map keyed by folder name -> that folder's additive IAM bindings (same shape as Section 1, one level up)."
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
locals {
  # flatten one level only: folder -> its bindings, never folder -> bindings -> nested-anything
  folder_bindings_flat = merge([
    for folder_name, bindings in var.folder_iam_bindings_additive : {
      for bkey, b in bindings : "${folder_name}::${bkey}" => merge(b, { folder_name = folder_name })
    }
  ]...)
}

resource "google_folder_iam_member" "additive" {
  for_each = local.folder_bindings_flat

  folder = google_folder.this[each.value.folder_name].id
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
```

> Note: this is the one place a `merge([for ... : { for ... }])` two-level
> flatten shows up — it's the repo's documented escape hatch for "avoid
> nested `for_each`" (flatten the data, not the loop). If this gets
> unwieldy, prefer the factory pattern (Section 8) with one YAML file per
> folder instead of a nested map literal.

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

  folder_iam_bindings_additive = {
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
}
```

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
    folder_id = string
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
  description = "Map keyed by project_id -> that project's additive IAM bindings."
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
# project/iam.tf  (same flatten pattern as folder/iam.tf)
locals {
  project_bindings_flat = merge([
    for project_id, bindings in var.project_iam_bindings_additive : {
      for bkey, b in bindings : "${project_id}::${bkey}" => merge(b, { project_id = project_id })
    }
  ]...)
}

resource "google_project_iam_member" "additive" {
  for_each = local.project_bindings_flat

  project = google_project.this[each.value.project_id].project_id
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
```

**Usage:**
```hcl
module "projects" {
  source = "../project"

  projects = {
    "marketing-ecommerce-prod" = {
      folder_id = module.folders.folder_ids["Production"]
      labels = {
        team = "marketing", environment = "prod", cost_center = "12345"
        app = "ecommerce", owner = "john.doe", location = "us"
      }
    }
  }

  project_iam_bindings_additive = {
    "marketing-ecommerce-prod" = {
      app_owner = {
        member = "group:marketing-app-owners@example.com"
        role   = "roles/viewer"
      }
    }
  }
}
```

---

## 5. `identities` module (Service Accounts)

**Responsibility:** create Service Accounts and grant **their own**
project/resource-scoped roles. Stays a **separate** module — an SA's
lifecycle isn't tied to one project's IAM the way a group grant is; SAs get
referenced by other modules (WIF, Cloud Functions, GKE workloads) after
creation, so they need stable, independent outputs.

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

**Usage:**
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

Confirms the earlier conclusion: **an SA is never attached to the
hierarchy itself** — it's created inside a project and only ever *granted*
roles at project/resource scope (the one exception, a bootstrap/deployer
SA needing folder/org-scope grants, is handled by also passing that SA's
`serviceAccount:` member into `folder`'s or `organization`'s
`iam_bindings_additive` directly — no special-casing needed in `identities`
itself).

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
  project_iam_bindings_additive = {
    "marketing-ecommerce-prod" = {
      restricted_secret_read = {
        member = "serviceAccount:${module.identities.emails["wl-ecommerce-sa"]}"
        role   = module.custom_roles.custom_role_ids["customSecretReaderNoList"]
      }
    }
  }
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
  name         = "deny-policy-${var.target_id}"
  display_name = "Deny policy for ${var.target_id}"

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

**Usage — e.g. Isolated folder, guaranteeing no external identity can ever
be granted access even by mistake:**
```hcl
module "isolated_folder_deny" {
  source    = "../iam-deny-policy"
  scope     = "folders"
  target_id = module.folders.folder_ids["Isolated"]

  deny_rules = [{
    denied_principals  = ["principalSet://goog/public:all"]
    denied_permissions = ["*"]
    exception_principals = [
      "principal://goog/subject/isolated-workload-sa@isolated-project.iam.gserviceaccount.com"
    ]
    reason = "Isolated folder must never be reachable by any principal except its own dedicated workload SA, regardless of any accidental broader IAM grant."
  }]
}
```

---

## 8. Scaling to hundreds of projects/folders — the factory pattern

Hand-writing one `projects = { ... }` map entry (or `folders = { ... }`)
per project/folder in `.tf` code doesn't scale past a few dozen. CFF's
answer: **one YAML file per project, one generic `for_each` reads all of
them** — no `.tf` changes needed to onboard a new project.

### Two factories, matching two different review tiers

| Factory | Scope | Contains | Reviewer |
|---|---|---|---|
| **`project-factory`** | Project | Project attributes **and** its own project-level IAM, combined in one YAML per project | App team + light DevOps review |
| **`hierarchical-iam-factory`** | Folder / Org | Only folder/org-level bindings — not owned by any single project | Security / DevOps only |

```yaml
# factories/projects/marketing-ecommerce-prod.yaml
project_id: marketing-ecommerce-prod
folder_id: "987654321"
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
      folder_id = p.folder_id
      labels    = p.labels
    }
  }

  project_iam_bindings_additive = {
    for pid, p in local.projects_data : pid => p.iam_bindings_additive
  }
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

  folder_iam_bindings_additive = {
    for k, v in local.hier_iam_data : v.folder_name => v.bindings
  }
}
```

### Why this needs no changes to any module above

Every module in Sections 2–6 already takes flat map/list variables — that's
exactly what makes them factory-compatible without modification. The
factory only changes **how** those variables get populated (YAML +
`for_each`, instead of a hand-written literal).

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

1. `organization` (Section 2) — data source + org-level IAM.
2. `folder` (Section 3) — depends on org_id from step 1.
3. `project` (Section 4) — depends on folder_ids from step 2.
4. `identities` (Section 5) — depends on project_ids from step 3.
5. `custom-iam-roles` (Section 6) — independent, but typically referenced
   by step 3/4's `iam_bindings_additive.role`.
6. `iam-deny-policy` (Section 7) — build only when a real exception case
   appears.
7. `project-factory` + `hierarchical-iam-factory` (Section 8) — once
   modules 1–4 are stable and project count starts exceeding what's
   comfortable to hand-write.
8. `workload-identity-federation` (Section 9) — deferred until the CI/CD
   pipeline (env0) is ready to move off human impersonation.

For each module: standard file layout (`main.tf`/`variables.tf`/
`outputs.tf`/`versions.tf`/`README.md`), `examples/basic/`, `terraform fmt`
+ `validate` + a real `plan` against a sandbox project before merge — per
`agents.md`'s checklist.
