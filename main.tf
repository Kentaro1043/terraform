terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "6.31.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.26.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.2.0"
    }
  }

  backend "gcs" {
    bucket = "gcs-tfstate-kentaro"
    prefix = "terraform/state"
  }
}

provider "oci" {}

provider "google" {
  project = var.gcp_project_id
  region  = "us-west1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "google_storage_bucket" "gcs_tfstate_bucket" {
  name          = "gcs-tfstate-kentaro"
  storage_class = "STANDARD"
  location      = "US-WEST1"

  uniform_bucket_level_access = false

  versioning {
    enabled = false
  }
}
