# ==============================================================================
# STAGE 03: Service projects + Shared VPC attachment + validation VMs
# ==============================================================================
# Consumes host project IDs from 01 and subnet self-links from 02, then calls
# the service-projects module to create one service project per host, attach it
# to the host Shared VPC, and provision a VM on the host subnet.
# ==============================================================================

data "terraform_remote_state" "host_projects" {
  backend = "gcs"
  config = {
    bucket = "finops-foundation-tfstate"
    prefix = "01-folders-host-projects"
  }
}

data "terraform_remote_state" "hub_spoke" {
  backend = "gcs"
  config = {
    bucket = "finops-foundation-tfstate"
    prefix = "02-hub-spoke"
  }
}

locals {
  terraform_sa_email = data.terraform_remote_state.host_projects.outputs.terraform_sa_emails[var.hub_project_key]
}

module "service_projects" {
  source = "../../service-projects"

  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  terraform_user     = var.terraform_user

  # Rekey by the real host project ID (resolved from stage 01), and inject the
  # subnet self-link resolved from stage 02 based on subnet_source.
  hosts = {
    for k, v in var.hosts :
    data.terraform_remote_state.host_projects.outputs.project_ids[v.host_project_key] => {
      service_project_id   = v.service_project_id
      service_project_name = v.service_project_name
      vm = merge(v.vm, {
        subnetwork_self_link = v.subnet_source == "hub" ? data.terraform_remote_state.hub_spoke.outputs.hub_subnet_self_link : data.terraform_remote_state.hub_spoke.outputs.spoke_subnet_self_links[v.subnet_source]
      })
    }
  }
}


