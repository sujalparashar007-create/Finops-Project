terraform {
  backend "gcs" {
    bucket = "finops-foundation-tfstate"
    prefix = "02-hub-spoke"
  }
}
