terraform {
  backend "gcs" {
    bucket = "finops-foundation-tfstate"
    prefix = "01-folders-host-projects"
  }
}
