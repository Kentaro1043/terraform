resource "oci_core_security_list" "compute_default-security-list" {
  compartment_id = oci_identity_compartment.compute_compartment.id
  display_name   = "compute_default-security-list"
  vcn_id         = oci_core_vcn.compute_vcn.id
  ingress_security_rules {
    description = "SSH Remote Login Protocol"
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    description = "Destination Unreachable: Fragmentation Needed and Don't Fragment was Set"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "0.0.0.0/0"
    stateless = "false"
  }
  ingress_security_rules {
    description = "Destination Unreachable"
    icmp_options {
      type = "3"
    }
    protocol  = "1"
    source    = "10.1.0.0/16"
    stateless = "false"
  }
  egress_security_rules {
    description      = "All traffic for all ports"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
}

resource "oci_core_security_list" "compute_private-security-list" {
  compartment_id = oci_identity_compartment.compute_compartment.id
  display_name   = "compute_private-security-list"
  vcn_id         = oci_core_vcn.compute_vcn.id
  ingress_security_rules {
    description = "SSH Remote Login Protocol"
    protocol    = "6"
    source      = "10.1.0.0/16"
    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    description = "Destination Unreachable: Fragmentation Needed and Don't Fragment was Set"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "0.0.0.0/0"
    stateless = "false"
  }
  ingress_security_rules {
    description = "Destination Unreachable"
    icmp_options {
      type = "3"
    }
    protocol  = "1"
    source    = "10.1.0.0/16"
    stateless = "false"
  }
  egress_security_rules {
    description      = "All traffic for all ports"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
}
