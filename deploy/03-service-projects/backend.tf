terraform {
  backend "gcs" {
    bucket = "finops-foundation-tfstate"
    prefix = "03-service-projects"
  }
}
