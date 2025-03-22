resource "oci_core_instance" "oci_compute" {
  availability_domain = "EXYG:AP-OSAKA-1-AD-1"
  compartment_id      = oci_identity_compartment.oke_compartment.id
  display_name = "oci_compute"
  shape = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = "6"
    ocpus         = "1"
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaldeqjomudapby2r4vqzkqpgfbltlzqdsoznfbrfy3oxhrro5lfha" // Ubuntu 24.04 Minimal aarch64
    source_type             = "image"
  }
  is_pv_encryption_in_transit_enabled = "true"
  create_vnic_details {
    assign_ipv6ip             = "false"
    assign_private_dns_record = "true"
    assign_public_ip          = "false"
    display_name              = "oci_compute_vnic"
    subnet_id                 = oci_core_vcn.oke_vcn.id
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
