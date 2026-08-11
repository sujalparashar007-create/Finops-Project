module "folders" {
  source = "../../"

  parent = "organizations/123456789"
  names  = ["network", "development"]

  folder_iam_bindings = {
    dev_creator = {
      folder_key = "development"
      role       = "roles/resourcemanager.projectCreator"
      member     = "group:dev-team@example.com"
    }
  }
}
