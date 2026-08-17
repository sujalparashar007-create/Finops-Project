
​# Hub-and-Spoke Architecture Review (Layered Model)

This document captures a proposed layered hub-and-spoke architecture, a review of its
correctness, and open items to address before building the Terraform modules for it
(target use case: single-VM validation, extensible to GKE).

---

## Proposed Architecture (as submitted)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           1. ORGANIZATION LAYER                             │
│                                                                              │
│  Organization: NOT SPECIFIED IN GUIDE                                        │
│  Org ID: YOUR_ORG_ID                                                         │
│                                                                              │
│  Org-level controls:                                                         │
│    • Hierarchical Firewall Policy: fp-{project_prefix}-foundation            │
│    • IAM / org policy / governance                                           │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                              2. FOLDER LAYER                                │
│                                                                              │
│  fldr-network                                                                │
│  fldr-development                                                            │
│  fldr-nonproduction                                                          │
│  fldr-production                                                             │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         3. NETWORK / HOST PROJECT LAYER                      │
│                                                                              │
│  Hub project                                                                  │
│    • prj-net-hub                                                              │
│    • vpc-{project_prefix}-hub                                                 │
│    • sb-hub-{region} → 10.0.0.0/24                                            │
│    • Cloud Router + Cloud NAT                                                 │
│    • DNS hub / inbound forwarding                                             │
│                                                                              │
│  Spoke host projects                                                          │
│    • prj-d-spoke  → vpc-{project_prefix}-d-spoke                              │
│      - subnet: sb-d-gke-{region}                                              │
│      - nodes: 10.10.0.0/20                                                    │
│      - pods: 10.20.0.0/16                                                     │
│      - services: 10.30.0.0/20                                                 │
│                                                                              │
│    • prj-n-spoke  → vpc-{project_prefix}-n-spoke                              │
│      - subnet: sb-n-gke-{region}                                              │
│      - nodes: 10.11.0.0/20                                                    │
│      - pods: 10.21.0.0/16                                                     │
│      - services: 10.31.0.0/20                                                 │
│                                                                              │
│    • prj-p-spoke  → vpc-{project_prefix}-p-spoke                              │
│      - subnet: sb-p-gke-{region}                                              │
│      - nodes: 10.12.0.0/20                                                    │
│      - pods: 10.22.0.0/16                                                     │
│      - services: 10.32.0.0/20                                                 │
│                                                                              │
│  Connectivity                                                                 │
│    • Hub ↔ Dev peering                                                        │
│    • Hub ↔ Nonprod peering                                                    │
│    • Hub ↔ Prod peering                                                       │
│    • No transitive spoke-to-spoke routing                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          4. CONSUMPTION LAYER                                │
│                    (Introduced in Phase 7 / 4-projects)                      │
│                                                                              │
│  Service / workload projects consume Shared VPC subnets from spoke hosts     │
│                                                                              │
│  Development consumption                                                      │
│    • GKE service project(s) attach to prj-d-spoke as Shared VPC consumers    │
│    • Clusters use:                                                            │
│      - spoke_vpc_self_link                                                    │
│      - gke_subnet_self_link                                                   │
│      - pods_range_name = gke-pods                                             │
│      - services_range_name = gke-services                                     │
│                                                                              │
│  Nonproduction consumption                                                    │
│    • GKE service project(s) attach to prj-n-spoke                             │
│    • Workloads consume subnet/IP ranges from nonprod spoke                    │
│                                                                              │
│  Production consumption                                                       │
│    • GKE service project(s) attach to prj-p-spoke                             │
│    • Production clusters/apps consume prod spoke networking                   │
│                                                                              │
│  Typical consumers                                                            │
│    • GKE clusters                                                             │
│    • Node pools                                                               │
│    • Kubernetes services                                                      │
│    • Internal load balancers                                                  │
│    • Private workloads needing Google API access via PGA/NAT                  │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           5. WORKLOAD LAYER                                  │
│                                                                              │
│  Applications deployed onto GKE in service projects                          │
│    • dev apps                                                                 │
│    • nonprod apps                                                             │
│    • prod apps                                                                │
│                                                                              │
│  These workloads inherit networking from the corresponding spoke VPC         │
│  through Shared VPC attachment.                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Review Verdict

Overall **correct and sound** — matches Google's enterprise foundation blueprint pattern
(org → folder → network/host project → Shared VPC consumption → workload). Confirmed good:

- Folder structure (`fldr-network`, `fldr-development`, `fldr-nonproduction`, `fldr-production`)
  matches Google's standard enterprise foundation layout.
- Hub as a dedicated network host project, with separate spoke host projects per
  environment, is the correct Shared VPC pattern (host = network owner, service
  projects = consumers via `roles/compute.networkUser`).
- CIDR ranges for dev/nonprod/prod (nodes/pods/services) do not overlap — safe for
  future peering expansion or migration to NCC.
- Calling out "no transitive spoke-to-spoke routing" is accurate, not a mistake —
  see Finding 1 below for the full implication and options.

## Findings / Open Items

### Finding 1 — VPC Peering's transitive routing limitation (detailed)

**The core rule:** VPC Peering only connects the two networks you explicitly peer — it
does **not** forward traffic through a third network, even if that third network is
peered with both.

In this architecture:
- Hub ↔ Dev spoke = peered ✅
- Hub ↔ Nonprod spoke = peered ✅
- Hub ↔ Prod spoke = peered ✅
- Dev ↔ Nonprod (via Hub) = **NOT connected**, even though both are peered to Hub ❌

Analogy: three people (Dev, Hub, Prod) where Dev and Prod both know Hub personally, but
Dev and Prod have never met — Hub can't introduce them just by being a common friend.
GCP peering has no "relay" concept.

> **Correction:** an earlier draft of this finding illustrated the problem with "Prod
> reaching something shared that lives in the Dev spoke." That is not a realistic or
> recommended design — you should never place something Prod depends on inside a
> lower-trust environment spoke like Dev. Shared/common resources belong in the **Hub**
> itself (or a dedicated shared-services spoke), never in an environment-specific spoke.
> The corrected, realistic triggers for this limitation are below.

**Realistic triggers for this limitation (none involve one env-spoke depending on
another):**
1. **On-prem connectivity via the Hub** — VPN/Interconnect terminates in the Hub, and
   *every* spoke (dev, nonprod, prod) independently needs to reach on-prem resources
   through it. This is the most common real case.
2. **Genuinely shared services hosted in the Hub itself** (not a spoke) — e.g., a
   central DNS resolver, NVA/firewall appliance, or shared CI/CD runner — reachable by
   all spokes because it sits in the Hub, which every spoke peers with directly.
3. A shared, environment-agnostic service that any spoke needs — this should live in
   the Hub or its own dedicated shared-services spoke, never inside Dev/Nonprod/Prod.

**How to solve on-prem-via-Hub reachability (GCP):**
1. **Custom route advertisement on peering** (`export_custom_routes` on the Hub-side
   peering, `import_custom_routes` on the Spoke-side peering) — propagates on-prem
   CIDRs learned by the Hub's Cloud Router (via VPN/Interconnect BGP) out to each
   spoke. Works, but is configured **per peering pair** — every Hub↔Spoke pair needs
   its own export/import flags set, and it only carries specific routes, not full
   transitive reachability between spokes themselves.
2. **Network Connectivity Center (NCC) hub-and-spoke model** — GCP's purpose-built
   replacement for pairwise peering. See comparison table below.

**Recommendation:** if all that's needed is spoke↔hub NAT/DNS with fully isolated
environments (no cross-env communication) plus each spoke reaching on-prem through the
Hub, plain VPC Peering with export/import custom routes as drawn is correct and
simpler. Only move to NCC if the number of spokes grows large, spoke-to-spoke
reachability through the Hub is required, or non-VPC spokes (SD-WAN/NVA appliances)
need to attach. Retrofitting later means re-architecting connectivity, so decide this
up front.

#### NCC vs. export/import custom routes — what's actually different

Export/import custom routes is a feature bolted onto pairwise VPC Peering — it doesn't
change the topology, it just lets specific routes cross a specific peering connection.
NCC replaces pairwise peering with a real hub construct.

| | Export/Import custom routes | Network Connectivity Center (NCC) |
|---|---|---|
| **Topology** | Bilateral peering — each Hub↔Spoke pair is a separate peering resource | A single hub resource that spokes *attach* to — a true star topology |
| **Adding a new spoke** | New spoke needs its own peering to Hub, plus its own export/import flags | New spoke just attaches to the existing NCC hub — inherits reachability automatically |
| **Route management** | Distributed — every peering pair has its own config to maintain | Centralized — one route table at the hub |
| **Scale** | Config grows per-pair; gets unwieldy with many spokes | Designed for many spokes; adding the 20th is as easy as the 2nd |
| **What can be a "spoke"** | Only VPCs (peering is VPC-to-VPC only) | VPC spokes, hybrid spokes (VPN/Interconnect), router appliance spokes (3rd-party SD-WAN/NVA), producer VPC spokes |
| **Transitivity** | Only propagates the specific routes exported/imported — not full mesh by default | Transitive by design — any attached spoke can reach any other through the hub, subject to hub-level policy |

### Finding 1a — Azure equivalent (for comparison, since this foundation may sit
alongside Azure landing zones)

Azure has the same underlying non-transitive VNet peering limitation, but solves
on-prem-via-Hub reachability with a **named peering feature** rather than manual route
flags:

- Hub VNet peering → **"Allow gateway transit"**
- Spoke VNet peering → **"Use remote gateways"**

With these set, on-prem routes learned via the Hub's VPN/ExpressRoute gateway (BGP)
propagate automatically to every peered spoke — this is Microsoft's own standard
hub-spoke reference pattern.

**Constraint to be aware of:** a spoke VNet can enable "Use remote gateways" on **only
one** peering connection at a time — a VNet must either own its own gateway or consume
exactly one remote gateway, never both and never more than one source. Azure enforces
this to avoid ambiguous/asymmetric route propagation (if two hubs both pushed on-prem
routes into the same spoke, there'd be no clean tie-breaker for return traffic). If a
spoke needs reachability to multiple on-prem sites, those circuits should converge at
one Hub (one gateway, multiple ExpressRoute/VPN connections terminated there) rather
than fanning the spoke out to multiple hubs. Same scaling pressure as GCP pushes larger
Azure designs toward **Virtual WAN** (Azure's equivalent of NCC) instead of plain
peering + gateway transit.

### Finding 2 — Hub subnet size

`sb-hub-{region}` is sized `10.0.0.0/24` (256 IPs). Fine if the Hub only hosts
Cloud NAT/Router + DNS forwarding. If bastion hosts, NVAs, or other hub-resident VMs
are added later, consider `/22` instead to avoid a resize.

### Finding 3 — Single-VM goal vs. GKE-shaped template

The stated goal is a single-VM validation build, but Layers 3–4 are GKE-shaped
(secondary alias ranges for pods/services). A plain VM doesn't need pod/service
ranges — just a primary subnet range with Private Google Access enabled. Recommend
adding a simplified "VM path" alongside the GKE path in Layers 4–5 so the module
isn't over-provisioned for the single-VM use case:
- Spoke host project subnet: primary range only (e.g., `sb-d-vm-{region}` →
  `10.10.0.0/24`), PGA enabled.
- Service project (consumer) attaches via Shared VPC, VM placed directly on that
  subnet — no GKE-specific alias ranges required.

### Finding 4 — Firewall rules per-VPC

Layer 3 only references the org-level hierarchical firewall policy
(`fp-{project_prefix}-foundation`). Add explicit per-VPC ingress/egress firewall
rules (tag- or service-account-based) for the VM/GKE traffic — the hierarchical
policy sets guardrails, but each spoke VPC still needs its own rules for
intra-VPC and Hub↔spoke traffic (SSH/IAP ingress, health checks, NAT egress, etc.).

---

## Layered Terraform Module Structure

Mirrors the pattern used in `personal-ies-azure-foundation\docs\architecture\design-document.md`
(Section 3 — Folder Structure / Section 4 — How the Layers Connect / Section 6 — Build
Order): reusable, stateless **modules** are written first, then **numbered stage
directories** apply them in dependency order, each stage holding its own Terraform
state and reading earlier stages via `terraform_remote_state`. Each layer in this
architecture becomes its own directory so it can be tasked, reviewed, and applied
independently.

```
terraform-google-foundation/
│
├── docs/
│   └── hub-and-spoke/
│       ├── hub-and-spoke-architecture-review.md   ← this file
│       └── implementation-plan.md
│
│  ═══════════════════════════════════════════════════════
│  MODULES — write these FIRST (no state, reusable)
│  ═══════════════════════════════════════════════════════
│
├── modules/
│   ├── org-policy/              ← INPUT: org_id, project_prefix
│   │                              OUTPUT: policy_id
│   │                              (single source for hierarchical firewall
│   │                              policy + org IAM — nobody else recreates this)
│   │
│   ├── folder/                  ← INPUT: name, parent_id
│   │                              OUTPUT: folder_id
│   │                              (single source for folder creation — called
│   │                              once per folder, never duplicated inline)
│   │
│   ├── project/                 ← INPUT: name, folder_id (from modules/folder),
│   │                                     billing_account, apis[] to enable
│   │                              OUTPUT: project_id, project_number
│   │                              (SINGLE SOURCE for GCP Project creation — the
│   │                              same role Azure's `subscription` module plays:
│   │                              billing/IAM/blast-radius boundary. Every module
│   │                              that needs "a project to live in" — hub, spoke,
│   │                              service-project — takes project_id as an INPUT
│   │                              from here. Without this module, project
│   │                              creation would get duplicated inline inside
│   │                              hub/spoke, which breaks the single-source rule.)
│   │
│   ├── hub/                     ← INPUT: project_id (from modules/project),
│   │                                     hub_cidr, region
│   │                              OUTPUT: vpc_self_link, subnet_self_link,
│   │                                      nat_ip, dns_inbound_ip
│   │                              (SINGLE SOURCE for the Hub network. Every other
│   │                              module that needs "the Hub" — spoke, peering,
│   │                              firewall — consumes THIS module's outputs.
│   │                              Nobody else defines a Hub VPC/NAT/DNS resource
│   │                              anywhere else. Note: hub no longer creates its
│   │                              own project — it takes project_id from
│   │                              modules/project as an input.)
│   │
│   ├── spoke/                   ← INPUT: project_id (from modules/project),
│   │                                     spoke_cidr(s), mode ("vm" | "gke"),
│   │                                     hub_vpc_self_link (from modules/hub)
│   │                              OUTPUT: vpc_self_link, subnet_self_link
│   │                              (mode flag controls whether pod/service alias
│   │                              ranges are created — see Finding 3. Takes both
│   │                              the project and the Hub's output as inputs,
│   │                              never redefines either.)
│   │
│   ├── peering/                  ← INPUT: hub_vpc_self_link (from modules/hub),
│   │                                     spoke_vpc_self_link (from modules/spoke),
│   │                                     export_custom_routes, import_custom_routes
│   │                              OUTPUT: peering_name
│   │                              (export/import flags exposed per Finding 1.
│   │                              Consumes modules/hub + modules/spoke outputs —
│   │                              doesn't own or duplicate either VPC definition.)
│   │
│   ├── firewall/                 ← INPUT: vpc_self_link (from modules/hub OR
│   │                                     modules/spoke — same module either way),
│   │                                     rules[]
│   │                              OUTPUT: rule_ids
│   │                              (per-VPC rules — Finding 4. One reusable module
│   │                              called once per VPC, not a separate copy per env.)
│   │
│   └── service-project/          ← INPUT: host_project_id (from modules/project),
│                                     subnet_self_link (from modules/spoke)
│                                     OUTPUT: service_project_id
│                                     SIDE EFFECTS: grants roles/compute.networkUser
│                                     (Shared VPC attach — Layer 4 consumption.
│                                     Also creates its OWN project via
│                                     modules/project — a service project is a
│                                     distinct project from the spoke host project.)
│
│  ═══════════════════════════════════════════════════════
│  STAGES — apply these IN ORDER (each holds state)
│  ═══════════════════════════════════════════════════════
│
├── 0-bootstrap/                 ← platform wrapper
│   ├── main.tf                    seed project, API enablement,
│   └── backend.tf                 Terraform SA, GCS state bucket
│
├── 1-org/                        ← calls modules/org-policy
│   └── main.tf                     reads Stage 0 remote state (SA/project)
│
├── 2-folders/                    ← calls modules/folder × 4
│   └── main.tf                     fldr-network, fldr-development,
│                                    fldr-nonproduction, fldr-production
│
├── 3-host-projects/              ← calls modules/project × 4 (NEW STAGE)
│   └── main.tf                     one project per env: hub host project in
│                                    fldr-network, dev/nonprod/prod spoke host
│                                    projects in their respective folders.
│                                    reads Stage 2 folder_id map.
│                                    → this is the only place modules/project
│                                      is instantiated for host projects
│
├── 4-networks-hub-and-spoke/     ← Layer 3 (Network/Host Project)
│   ├── hub.tf                      calls modules/hub ONCE
│   │                               reads Stage 3's REMOTE STATE OUTPUT
│   │                               project_id["hub"] (cross-stage read)
│   │                               → this is the only place modules/hub is
│   │                                 instantiated in the whole repo
│   ├── spokes.tf                   calls modules/spoke, for_each {dev, nonprod, prod}
│   │                               reads Stage 3's REMOTE STATE OUTPUT
│   │                               project_id[env] (cross-stage read)
│   │                               reads hub.tf's module.hub.vpc_self_link directly
│   │                               (same stage → direct module reference for the
│   │                               Hub, no remote state needed for that part)
│   │                               dev spoke instantiated first in mode="vm"
│   ├── peering.tf                  calls modules/peering, for_each spoke
│   │                               reads module.hub.* and module.spoke[env].*
│   │                               directly (same stage, same reasoning as above)
│   └── firewall.tf                 calls modules/firewall once for module.hub.vpc_self_link,
│                                    then once per module.spoke[env].vpc_self_link
│
└── 5-projects/                   ← Layer 4 (Consumption) + Layer 5 (Workload)
    └── instances/
        ├── dev-vm/                  calls modules/service-project (which itself
        │                            calls modules/project internally to create
        │                            the service project) + compute VM
        │                            reads Stage 4's REMOTE STATE OUTPUT
        │                            (spoke_subnets["dev"]) — this is a separate
        │                            stage/state file, so it cannot reference
        │                            module.spoke directly; Stage 4 must expose
        │                            it via an `output {}` block first
        ├── nonprod-vm/              (deferred until dev-vm validated)
        └── prod-vm/                 (deferred until dev-vm validated)
```

### Reuse pattern — one module, one source of truth (the "hub" example)

The rule: **whatever concept a module represents, it is defined in exactly one
module folder, and every consumer — whether in the same stage or a different one —
reads that module's *output*, never re-declares the resource itself.** Using `hub` as
the running example:

1. **`modules/hub/`** is the only place a Hub VPC, subnet, Cloud Router, Cloud NAT, or
   DNS forwarding rule is ever defined. No other module or stage file contains a
   `google_compute_network` resource for the Hub.
2. **Same-stage consumers** (`spokes.tf`, `peering.tf`, `firewall.tf` — all inside
   `4-networks-hub-and-spoke/`) reference it directly as a Terraform module output,
   because they share the same state file. Note `project_id` for both hub and each
   spoke comes from Stage 3's remote state (cross-stage), while the Hub's own
   networking output is a direct same-stage module reference:
   ```hcl
   # 4-networks-hub-and-spoke/hub.tf
   data "terraform_remote_state" "host_projects" {
     backend = "gcs"
     config  = { bucket = "tf-state-terraform-google-foundation", prefix = "3-host-projects" }
   }

   module "hub" {
     source     = "../modules/hub"
     project_id = data.terraform_remote_state.host_projects.outputs.project_id["hub"]
     hub_cidr   = var.hub_cidr
     region     = var.region
   }

   # 4-networks-hub-and-spoke/spokes.tf
   module "spoke" {
     for_each          = var.spokes
     source            = "../modules/spoke"
     project_id        = data.terraform_remote_state.host_projects.outputs.project_id[each.key]
     hub_vpc_self_link = module.hub.vpc_self_link   # ← direct reference, no remote state
     mode              = each.value.mode
   }

   # 4-networks-hub-and-spoke/peering.tf
   module "peering" {
     for_each            = var.spokes
     source              = "../modules/peering"
     hub_vpc_self_link   = module.hub.vpc_self_link
     spoke_vpc_self_link = module.spoke[each.key].vpc_self_link
   }
   ```
3. **Cross-stage consumers** (Stage `5-projects`, a different state file) can't
   reference `module.hub` directly — Terraform modules don't span state boundaries.
   Stage 4 must explicitly re-expose what it needs via its own `output {}` block, and
   Stage 5 reads it through `terraform_remote_state`:
   ```hcl
   # 4-networks-hub-and-spoke/outputs.tf
   output "hub_nat_ip"      { value = module.hub.nat_ip }
   output "spoke_subnets"   { value = { for k, s in module.spoke : k => s.subnet_self_link } }

   # 5-projects/instances/dev-vm/main.tf
   data "terraform_remote_state" "networks" {
     backend = "gcs"
     config  = { bucket = "tf-state-terraform-google-foundation", prefix = "4-networks-hub-and-spoke" }
   }
   locals {
     dev_subnet_self_link = data.terraform_remote_state.networks.outputs.spoke_subnets["dev"]
   }
   ```

Same rule applies to every other module: `folder` is only ever defined in
`modules/folder/` and called from `2-folders/`; `project` is only ever defined in
`modules/project/`, called once from `3-host-projects/` for host projects (hub +
spokes) and once more indirectly via `modules/service-project` for each workload's
own service project — never inlined anywhere else; `org-policy` only from `1-org/`.
No module's resource logic is ever copy-pasted into a stage file — stages only ever
*call* modules and wire their outputs together.

### How the layers connect (remote state)

```
Stage 0 creates Terraform SA + GCS state bucket
    └──► Stage 1 reads SA → applies org firewall policy
    └──► Stage 2 reads SA → creates folders

Stage 2 creates folder_id map {network, development, nonproduction, production}
    └──► Stage 3 reads folder_id map → creates one project per env
         (hub host project in fldr-network, dev/nonprod/prod spoke host
         projects in their folders) via modules/project

Stage 3 creates project_id map {hub, dev, nonprod, prod}
    └──► Stage 4 reads project_id["hub"] → creates Hub in that project
    └──► Stage 4 reads project_id[env] → creates each Spoke in its project

Stage 4 creates hub vpc_self_link + spoke vpc_self_link/subnet_self_link per env
    └──► Stage 4 (peering.tf) reads both → creates Hub↔Spoke peering pairs
    └──► Stage 5 reads spoke["dev"].subnet_self_link → creates its own service
         project (via modules/project inside modules/service-project) + attaches
         it as a Shared VPC consumer + deploys the VM

(Org policy in Stage 1 and Folders in Stage 2 can be applied in parallel — neither
depends on the other, both only need Stage 0's SA. Stage 3 needs Stage 2's folder
IDs, so it cannot start until Stage 2 completes.)
```

```hcl
# Example: 5-projects/instances/dev-vm reading Stage 4 remote state
data "terraform_remote_state" "networks" {
  backend = "gcs"
  config = {
    bucket = "tf-state-terraform-google-foundation"
    prefix = "4-networks-hub-and-spoke"
  }
}

locals {
  dev_subnet_self_link = data.terraform_remote_state.networks.outputs.spoke_subnets["dev"]
}
```

### Build order (mirrors Azure design-doc Section 6 format)

| Step | What to build | Depends on | Notes |
|---|---|---|---|
| 0 | Write all `modules/` | Nothing | Zero-dependency, reusable |
| 1 | Apply `0-bootstrap/` | Org access | Platform wrapper |
| 2 | Apply `1-org/` | Stage 0 | Can run parallel with Stage 2 (folders) |
| 2 | Apply `2-folders/` | Stage 0 | Can run parallel with Stage 1 (org policy) |
| 3 | Apply `3-host-projects/` (hub project + dev spoke project only) | Stage 2 folder IDs | Uses `modules/project` — the single source for all GCP project creation in this build |
| 4 | Apply `4-networks-hub-and-spoke/` (hub + **dev spoke only**, VM-mode) | Stage 3 project IDs | Decide Peering+export/import vs NCC before this step (Finding 1) |
| 5 | Apply `5-projects/instances/dev-vm/` | Stage 4 dev subnet | Validates end-to-end: IAP SSH, egress via Hub NAT |
| 6 | Replicate Stage 3 + Stage 4 for nonprod/prod (host projects + spoke networks) | Step 5 validated | Only after single-VM path proven |
| 7 | Extend `5-projects` to GKE mode | Step 6 | Reuses `modules/spoke` with `mode="gke"` |

---

## Implementation Tasks (Input / Steps / Output per stage)

Each stage below is a standalone, sequenced task. **Input** = what must already exist
(prior stage outputs, remote-state reads). **Steps** = what to build inside that stage
directory. **Output** = what it exposes via an `output {}` block for the next stage to
consume via `terraform_remote_state`.

### Task 0 — `modules/` (write all reusable modules)
- **Input:** Architecture review findings 1–4; no external state dependency.
- **Steps:**
  1. Create `modules/org-policy`, `modules/folder`, `modules/project`, `modules/hub`,
     `modules/spoke`, `modules/peering`, `modules/firewall`, `modules/service-project`.
  2. Each module: `variables.tf` (typed inputs, no hardcoded values), `main.tf`,
     `outputs.tf`. No `backend`/`provider` blocks inside modules.
  3. `modules/spoke` supports `mode = "vm" | "gke"` via a variable, not a copy-pasted module.
  4. `modules/peering` exposes `export_custom_routes` / `import_custom_routes` as variables
     (Finding 1); `modules/firewall` takes a `network_self_link` so it can be called once
     per VPC (Finding 4).
- **Output:** No state — reusable source only. Version-pin via a local path or module
  registry tag once stable.

### Task 1 — `0-bootstrap/`
- **Input:** Org-level access (Owner/Org Admin) to create the seed project.
- **Steps:**
  1. Create seed project, enable required APIs (`cloudresourcemanager`, `compute`,
     `iam`, `serviceusage`, `dns`).
  2. Create Terraform CI/CD service account + minimal IAM bindings.
  3. Create the GCS state bucket (versioned, uniform bucket-level access) that every
     later stage's backend block will point to.
- **Output:** `terraform_sa_email`, `state_bucket_name` (used in every later stage's
  `backend "gcs"` block).

### Task 2a — `1-org/`
- **Input:** Stage 0 `terraform_sa_email` (remote state).
- **Steps:**
  1. Call `modules/org-policy` to set org-level firewall policy + IAM guardrails.
  2. Can run in parallel with Task 2b (`2-folders/`) — no shared inputs.
- **Output:** `org_policy_id`.

### Task 2b — `2-folders/`
- **Input:** Stage 0 `terraform_sa_email` (remote state).
- **Steps:**
  1. Call `modules/folder` × 4: `fldr-network`, `fldr-development`,
     `fldr-nonproduction`, `fldr-production`.
  2. Can run in parallel with Task 2a (`1-org/`).
- **Output:** `folder_id` map, e.g. `{ network = "...", development = "...", nonproduction = "...", production = "..." }`.

### Task 3 — `3-host-projects/` (NEW STAGE)
- **Input:** Stage 2b `folder_id` map (remote state).
- **Steps:**
  1. Call `modules/project` × 4 (hub, dev, nonprod, prod), passing each project's
     matching `folder_id`, billing account, and required API list.
  2. This is the ONLY stage that creates host projects — never inline them elsewhere.
- **Output:** `project_id` map, e.g. `{ hub = "...", dev = "...", nonprod = "...", prod = "..." }`.

### Task 4 — `4-networks-hub-and-spoke/` (hub + dev spoke first)
- **Input:** Stage 3 `project_id` map (remote state, cross-stage).
- **Steps:**
  1. `hub.tf` — call `modules/hub` ONCE using `project_id["hub"]`. This is the only
     place `modules/hub` is instantiated (single source of truth).
  2. `spokes.tf` — call `modules/spoke` for `dev` only (`mode="vm"`), using
     `project_id["dev"]` (remote state) + `module.hub.vpc_self_link` (direct,
     same-stage reference).
  3. `peering.tf` — call `modules/peering` referencing `module.hub.*` and
     `module.spoke["dev"].*` directly. **Decide Peering (export/import routes) vs.
     NCC before this step — Finding 1.**
  4. `firewall.tf` — call `modules/firewall` once for the hub VPC and once for the
     dev spoke VPC (Finding 4).
- **Output:** `hub_vpc_self_link`, `spoke_subnets` map (e.g. `spoke_subnets["dev"]`).

### Task 5 — `5-projects/instances/dev-vm/`
- **Input:** Stage 4 `spoke_subnets["dev"]` (remote state, cross-stage).
- **Steps:**
  1. Call `modules/service-project` (internally calls `modules/project` again to
     create its own distinct service project, then attaches it to the dev spoke's
     Shared VPC host).
  2. Create the Compute Engine VM in the dev spoke VM-mode subnet: Private Google
     Access on, no external IP.
  3. Validate end-to-end: IAP-tunneled SSH reachability, egress via Hub Cloud NAT.
- **Output:** `vm_self_link`, `vm_internal_ip` — proof-of-concept complete for the
  single-VM goal.

### Task 6 — Expand `3-host-projects/` + `4-networks-hub-and-spoke/` to nonprod/prod
- **Input:** Task 5 validated (dev path proven end-to-end).
- **Steps:**
  1. Add `nonprod`/`prod` calls to `modules/project` in Stage 3 (no new module code).
  2. Add `nonprod`/`prod` calls to `modules/spoke`, `modules/peering`, `modules/firewall`
     in Stage 4, same pattern as dev.
- **Output:** Updated `project_id` and `spoke_subnets` maps now covering all three envs.

### Task 7 — Expand `5-projects/instances/` to nonprod-vm, prod-vm + GKE mode
- **Input:** Task 6 complete.
- **Steps:**
  1. Add `nonprod-vm/`, `prod-vm/` instance directories (same pattern as `dev-vm/`).
  2. Where GKE is required, call `modules/spoke` with `mode="gke"` instead of adding
     a second spoke module.
- **Output:** Full multi-env VM + GKE footprint, all traceable back to one module per
  concept.

---

## Next Steps

- Decide: VPC Peering (as drawn) vs. NCC hub-and-spoke, based on whether cross-spoke
  traffic via Hub is ever required (see Finding 1).
- Confirm Hub subnet sizing against actual planned Hub-resident resources (Finding 2).
- Define the simplified VM consumption path for the initial single-VM validation
  build (Finding 3), before generalizing to GKE.
- Add per-VPC firewall rule sets to the Terraform modules (Finding 4).
