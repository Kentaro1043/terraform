variable "oci_compartment_id" {
  description = "The OCID of the compartment to create the resources in"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cloudflare_email" {
  description = "The Cloudflare email address"
  type        = string
}

variable "cloudflare_api_key" {
  description = "The Cloudflare API key"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID"
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare account ID"
  type        = string
}

variable "ssh_key" {
  description = "The public SSH key to add to the instance"
  type        = string
}
