variable "oci_compartment_id" {
  description = "The OCID of the compartment to create the resources in"
  type        = string
}

variable "oci_ssh_key" {
  description = "The public SSH key to add to the instance"
  type        = string
}
