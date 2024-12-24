resource "oci_identity_compartment" "oke" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the OKE cluster"
  name           = "oke_compartment"
}
