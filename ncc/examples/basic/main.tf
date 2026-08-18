module "ncc" {
  source = "../../"

  hub_project_id = "example-hub-project"
  hub_name       = "ncc-hub"
  region         = "us-central1"

  vpc_spokes = {
    spoke-prod = {
      project_id    = "example-prod-project"
      vpc_self_link = "projects/example-prod-project/global/networks/prod-vpc"
    }
    spoke-dev = {
      project_id    = "example-dev-project"
      vpc_self_link = "projects/example-dev-project/global/networks/dev-vpc"
    }
  }

  labels = {
    env       = "example"
    terraform = "true"
  }
}
