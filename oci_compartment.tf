resource "oci_identity_compartment" "data_compartment" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the data server"
  name           = "data_compartment"
}

resource "oci_identity_compartment" "oke_compartment" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the OKE cluster"
  name           = "oke_compartment"
}
