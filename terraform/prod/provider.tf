terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.5"
}

provider "google" {
  project = "zeno-cy-dev-001"
  region  = "europe-west3"
}
