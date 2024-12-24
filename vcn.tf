resource "oci_core_vcn" "oke_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_vcn"
  dns_label      = "okevcn"
}

resource "oci_core_internet_gateway" "oke_ig" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_ig"
  enabled        = "true"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

resource "oci_core_nat_gateway" "oke_ngw" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_ngw"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_sgw"
  services {
    service_id = "ocid1.service.oc1.ap-osaka-1.aaaaaaaanpw2x646vasmcdktlznzhf7mwmcgf4hhmw5zepgspmseokxjyj4q"
  }
  vcn_id = oci_core_vcn.oke_vcn.id
}

resource "oci_core_route_table" "oke_routetable" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_routetable"
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
  vcn_id = oci_core_vcn.oke_vcn.id
}

resource "oci_core_subnet" "service_lb_subnet" {
  cidr_block                 = "10.0.20.0/24"
  compartment_id             = oci_identity_compartment.oke.id
  display_name               = "oke_svclbsubnet"
  dns_label                  = "okesvclbsubnet"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.oke_public-routetable.id
  security_list_ids          = ["${oci_core_vcn.oke_vcn.default_security_list_id}"]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}

resource "oci_core_subnet" "node_subnet" {
  cidr_block                 = "10.0.10.0/24"
  compartment_id             = oci_identity_compartment.oke.id
  display_name               = "oke_nodesubnet"
  dns_label                  = "okenodesubnet"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke_routetable.id
  security_list_ids          = ["${oci_core_security_list.node_sec_list.id}"]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  cidr_block                 = "10.0.0.0/28"
  compartment_id             = oci_identity_compartment.oke.id
  display_name               = "oke_k8sapisubnet"
  dns_label                  = "okek8sapi"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.oke_public-routetable.id
  security_list_ids          = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
  vcn_id                     = oci_core_vcn.oke_vcn.id
}

resource "oci_core_default_route_table" "oke_public-routetable" {
  display_name = "oke_public-routetable"
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_ig.id
  }
  manage_default_resource_id = oci_core_vcn.oke_vcn.default_route_table_id
}

resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_svclbseclist"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

resource "oci_core_security_list" "node_sec_list" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_nodeseclist"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-kix-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "10.0.0.0/28"
    stateless = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = "10.0.0.0/28"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.oke_vcn.id
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
  compartment_id = oci_identity_compartment.oke.id
  display_name   = "oke_k8sapisec"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-kix-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "10.0.10.0/24"
    stateless = "false"
  }
  vcn_id = oci_core_vcn.oke_vcn.id
}
