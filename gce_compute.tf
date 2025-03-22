resource "google_compute_instance" "gce_compute" {
  name         = "gce-compute"
  machine_type = "e2-micro"
  zone         = "us-west1-a"

  boot_disk {
    auto_delete = true
    device_name = "gce-compute"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20250313"
      size  = 30
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }


  network_interface {
    access_config {
      network_tier = "STANDARD"
    }
    stack_type = "IPV4_ONLY"
  }

  tags = ["http-server", "https-server"]

  metadata = {
    ssh-keys = var.ssh_key
  }
}
