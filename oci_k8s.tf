resource "oci_containerengine_cluster" "oke_cluster" {
  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }
  compartment_id = oci_identity_compartment.oke_compartment.id
  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id            = oci_core_subnet.kubernetes_api_endpoint_subnet.id
  }
  freeform_tags = {
    "OKEclusterName" = "oke_cluster"
  }
  kubernetes_version = "v1.31.1"
  name               = "oke_cluster"
  options {
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    persistent_volume_config {
      freeform_tags = {
        "OKEclusterName" = "oke_cluster"
      }
    }
    service_lb_config {
      freeform_tags = {
        "OKEclusterName" = "oke_cluster"
      }
    }
    service_lb_subnet_ids = [oci_core_subnet.service_lb_subnet.id]
  }
  type   = "BASIC_CLUSTER"
  vcn_id = oci_core_vcn.oke_vcn.id
}

resource "oci_containerengine_node_pool" "create_node_pool_details0" {
  cluster_id     = oci_containerengine_cluster.oke_cluster.id
  compartment_id = oci_identity_compartment.oke_compartment.id
  freeform_tags = {
    "OKEnodePoolName" = "pool1"
  }
  initial_node_labels {
    key   = "name"
    value = "oke_cluster"
  }
  kubernetes_version = "v1.31.1"
  name               = "oke_nodepool"
  node_config_details {
    freeform_tags = {
      "OKEnodePoolName" = "oke_nodepool"
    }
    is_pv_encryption_in_transit_enabled = "true"
    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }
    placement_configs {
      availability_domain = "EXYG:AP-OSAKA-1-AD-1"
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    size = "3"
  }
  node_eviction_node_pool_settings {
    eviction_grace_duration = "PT1H"
  }
  node_shape = "VM.Standard.A1.Flex"
  node_shape_config {
    memory_in_gbs = "6"
    ocpus         = "1"
  }
  node_source_details {
    boot_volume_size_in_gbs = "50"
    image_id                = "ocid1.image.oc1.ap-osaka-1.aaaaaaaajsvhzixv2n3ruuzb6snrnnebxbhu3opjzwwccjoyq7xo7ajjrnaa"
    source_type             = "IMAGE"
  }
  ssh_public_key = var.ssh_key
}
