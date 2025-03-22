provider "oci" {}
provider "google" {
  project = var.gcp_project_id
  region  = "us-west1"
}
