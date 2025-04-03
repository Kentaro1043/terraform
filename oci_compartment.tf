resource "oci_identity_compartment" "compute_compartment" {
  name           = "compute_compartment"
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the compute instance"
}

resource "oci_identity_compartment" "oke_compartment" {
  name           = "oke_compartment"
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the OKE cluster"
}
