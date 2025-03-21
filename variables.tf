variable "oci_compartment_id" {
  description = "The OCID of the compartment to create the resources in"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string

}

variable "ssh_key" {
  description = "The public SSH key to add to the instance"
  type        = string
}
