resource "oci_identity_compartment" "databases" {
  compartment_id = var.oci_compartment_id
  description    = "The compartment for the database server"
  name           = "databases_compartment"
}
