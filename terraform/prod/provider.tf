terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = "~> 1.5"
}

provider "google" {
  project = "zeno-cy-dev-001"
  region  = "europe-west3"
}
