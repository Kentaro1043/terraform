resource "google_compute_firewall" "allow_custom_ssh" {
  name    = "allow-custom-ssh"
  network = google_compute_instance.gce_compute.network_interface[0].network

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["50022"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["custom-ssh"]
}
