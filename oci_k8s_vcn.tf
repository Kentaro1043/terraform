resource "oci_core_vcn" "oke_vcn" {
  display_name   = "oke_vcn"
  compartment_id = oci_identity_compartment.oke_compartment.id
  cidr_block     = "10.0.0.0/16"
  dns_label      = "okevcn"
}

resource "oci_core_internet_gateway" "oke_ig" {
  display_name   = "oke_ig"
  compartment_id = oci_identity_compartment.oke_compartment.id
  enabled        = "true"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

resource "oci_core_nat_gateway" "oke_ngw" {
  display_name   = "oke_ngw"
  compartment_id = oci_identity_compartment.oke_compartment.id
  vcn_id         = oci_core_vcn.oke_vcn.id
}

resource "oci_core_service_gateway" "oke_sgw" {
  display_name   = "oke_sgw"
  compartment_id = oci_identity_compartment.oke_compartment.id
  services {
    service_id = "ocid1.service.oc1.ap-osaka-1.aaaaaaaanpw2x646vasmcdktlznzhf7mwmcgf4hhmw5zepgspmseokxjyj4q"
  }
  vcn_id = oci_core_vcn.oke_vcn.id
}

resource "oci_core_default_route_table" "oke_public-routetable" {
  display_name               = "oke_public-routetable"
  manage_default_resource_id = oci_core_vcn.oke_vcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_ig.id
  }
}

resource "oci_core_route_table" "oke_routetable" {
  display_name   = "oke_routetable"
  vcn_id         = oci_core_vcn.oke_vcn.id
  compartment_id = oci_identity_compartment.oke_compartment.id
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_ngw.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = "all-kix-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

resource "oci_core_subnet" "service_lb_subnet" {
  display_name               = "oke_svclbsubnet"
  cidr_block                 = "10.0.20.0/24"
  compartment_id             = oci_identity_compartment.oke_compartment.id
  dns_label                  = "okesvclbsubnet"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.oke_public-routetable.id
  security_list_ids          = [oci_core_vcn.oke_vcn.default_security_list_id, oci_core_security_list.service_lb_sec_list.id]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}

resource "oci_core_subnet" "node_subnet" {
  display_name               = "oke_nodesubnet"
  cidr_block                 = "10.0.10.0/24"
  compartment_id             = oci_identity_compartment.oke_compartment.id
  dns_label                  = "okenodesubnet"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke_routetable.id
  security_list_ids          = ["${oci_core_security_list.node_sec_list.id}"]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  display_name               = "oke_k8sapisubnet"
  cidr_block                 = "10.0.0.0/28"
  compartment_id             = oci_identity_compartment.oke_compartment.id
  dns_label                  = "okek8sapi"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.oke_public-routetable.id
  security_list_ids          = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}
