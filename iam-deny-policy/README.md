# iam-deny-policy — IAM Deny Policy

The only real exception mechanism — IAM Allow policies are purely additive
and cannot subtract a higher-level grant. `google_iam_deny_policy` expresses
"this principal/role is explicitly blocked here."

> **Warning:** `google_iam_deny_policy` is authoritative per (parent, name).
> Two different teams calling this module against the same `target_id` MUST
> use different `policy_name` values or they will silently overwrite each
> other's rules.
>
> **Note:** `target_id` must be the **numeric** folder/org ID (not its display
> name) when `scope = "folders"` or `scope = "organizations"` — folders and
> orgs have no string alias the way a project has a `project_id`. Passing a
> display name here will attach the policy to the wrong resource or fail
> outright. Only `scope = "projects"` accepts a string `project_id`.

## Usage

```hcl
module "isolated_folder_deny" {
  source    = "../iam-deny-policy"
  scope     = "folders"
  target_id = module.folders.folder_ids["Isolated"]
  policy_name = "isolated-external-access-guardrails"

  deny_rules = [{
    denied_principals  = ["principalSet://goog/public:all"]
    denied_permissions = ["*"]
    exception_principals = [
      "principal://goog/subject/isolated-workload-sa@isolated-project.iam.gserviceaccount.com"
    ]
    reason = "Isolated folder must never be reachable by any principal except its own dedicated workload SA."
  }]
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `scope` | `string` | `organizations`, `folders`, or `projects` |
| `target_id` | `string` | Org/folder/project ID to attach to |
| `policy_name` | `string` | Unique name for this policy (3-62 chars, lowercase/dash) |
| `deny_rules` | `list(object)` | Flat list of deny rules |

### `deny_rules` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `denied_principals` | `list(string)` | (required) | Principals to deny |
| `denied_permissions` | `list(string)` | (required) | Permissions/roles to deny |
| `exception_principals` | `list(string)` | `[]` | Explicitly exempted principals |
| `exception_permissions` | `list(string)` | `[]` | Explicitly exempted permissions |
| `denial_condition` | `object` | `null` | Optional CEL condition gating the deny rule (see below) |
| `reason` | `string` | (required) | Why this deny rule exists |

#### `denial_condition` object schema

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `string` | (required) | Short name for the condition |
| `expression` | `string` | (required) | CEL expression evaluating to a boolean |
| `description` | `string` | `""` | Human-readable purpose of the condition |
| `location` | `string` | `""` | Optional location string for the condition |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Full resource name of the deny policy |
| `parent` | Parent scope/target |

## Examples

See `examples/basic/` for a runnable root module.
