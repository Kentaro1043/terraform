resource "oci_core_vcn" "compute_vcn" {
  display_name   = "compute_vcn"
  compartment_id = oci_identity_compartment.compute_compartment.id
  cidr_block     = "10.1.0.0/16"
  dns_label      = "computevcn"
}

resource "oci_core_internet_gateway" "compute_ig" {
  display_name   = "compute_ig"
  compartment_id = oci_identity_compartment.compute_compartment.id
  vcn_id         = oci_core_vcn.compute_vcn.id
  enabled        = "true"
}

resource "oci_core_nat_gateway" "compute_ngw" {
  display_name   = "compute_ngw"
  compartment_id = oci_identity_compartment.compute_compartment.id
  vcn_id         = oci_core_vcn.compute_vcn.id
}

resource "oci_core_service_gateway" "compute_sgw" {
  display_name   = "compute_sgw"
  compartment_id = oci_identity_compartment.compute_compartment.id
  vcn_id         = oci_core_vcn.compute_vcn.id
  services {
    service_id = "ocid1.service.oc1.ap-osaka-1.aaaaaaaanpw2x646vasmcdktlznzhf7mwmcgf4hhmw5zepgspmseokxjyj4q"
  }
}

resource "oci_core_default_route_table" "compute_public-routetable" {
  display_name               = "compute_public-routetable"
  manage_default_resource_id = oci_core_vcn.compute_vcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.compute_ig.id
  }
}

resource "oci_core_route_table" "compute_routetable" {
  display_name   = "oke_routetable"
  vcn_id         = oci_core_vcn.compute_vcn.id
  compartment_id = oci_identity_compartment.compute_compartment.id
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.compute_ngw.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = "all-kix-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.compute_sgw.id
  }
}

resource "oci_core_subnet" "compute_subnet_public" {
  display_name               = "compute_subnet_public"
  compartment_id             = oci_identity_compartment.compute_compartment.id
  vcn_id                     = oci_core_vcn.compute_vcn.id
  cidr_block                 = "10.1.0.0/24"
  dns_label                  = "computepublic"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.compute_public-routetable.id
  security_list_ids          = [oci_core_security_list.compute_default-security-list.id]
}

resource "oci_core_subnet" "compute_subnet_private" {
  display_name               = "compute_subnet_private"
  compartment_id             = oci_identity_compartment.compute_compartment.id
  vcn_id                     = oci_core_vcn.compute_vcn.id
  cidr_block                 = "10.1.1.0/24"
  dns_label                  = "computeprivate"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.compute_public-routetable.id
  security_list_ids          = [oci_core_security_list.compute_private-security-list.id]
}
