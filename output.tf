output "oci_compute_public_ip" {
  value = oci_core_instance.oci_compute.public_ip
}

output "oci_compute_priavte_ip_for_node_sb" {
  value = oci_core_vnic_attachment.compute_vnic.create_vnic_details[0].private_ip
}

output "gce_public_ip" {
  value = google_compute_instance.gce_compute.network_interface[0].access_config[0].nat_ip
}

output "gce_private_ip" {
  value = google_compute_instance.gce_compute.network_interface[0].network_ip
}
