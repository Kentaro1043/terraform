resource "oci_core_instance" "oci_compute" {
  display_name        = "oci_compute"
  compartment_id      = oci_identity_compartment.compute_compartment.id
  availability_domain = "EXYG:AP-OSAKA-1-AD-1"
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = "6"
    ocpus         = "1"
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaax6cshnfkznyhssphxwn27v77z6dpp4miujcgaceq4v4vg5d7qqeq" // Ubuntu 24.04 Minimal aarch64
    source_type             = "image"
  }
  is_pv_encryption_in_transit_enabled = "true"
  create_vnic_details {
    assign_ipv6ip             = "false"
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    display_name              = "oci_compute_vnic"
    subnet_id                 = oci_core_subnet.compute_subnet_public.id
    hostname_label            = "oci"
  }
  metadata = {
    "ssh_authorized_keys" = var.ssh_key
  }
  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
}

resource "oci_core_vnic_attachment" "compute_vnic" {
  display_name = "oci_compute_vnic_k8s_attachment"
  instance_id  = oci_core_instance.oci_compute.id
  create_vnic_details {
    subnet_id                 = oci_core_subnet.node_subnet.id
    display_name              = "oci_compute_vnic_k8s"
    assign_public_ip          = "false"
    assign_private_dns_record = "true"
    assign_ipv6ip             = "false"
  }
}
