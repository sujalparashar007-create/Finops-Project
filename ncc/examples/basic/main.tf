module "ncc" {
  source = "../../"

  hub_project_id = "foundation-network"
  hub_name       = "ncc-hub"
  region         = "us-central1"

  vpc_spokes = {
    spoke-prod = {
      project_id    = "prod-project"
      vpc_self_link = "projects/prod-project/global/networks/prod-vpc"
    }
    spoke-dev = {
      project_id    = "dev-project"
      vpc_self_link = "projects/dev-project/global/networks/dev-vpc"
    }
  }

  labels = {
    env       = "prod"
    terraform = "true"
  }
}
