resource "oci_identity_compartment" "compute_compartment" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the compute instance"
  name           = "compute_compartment"
}

resource "oci_identity_compartment" "oke_compartment" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the OKE cluster"
  name           = "oke_compartment"
}
