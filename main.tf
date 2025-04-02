terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.32.0"
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
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}
