provider "google" {
  project     = "${var.project-name}"
  region      = "${var.region}"
}

// Create a new instance
resource "google_compute_instance" "default" {
  name         = "test-${uuid()}"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  // Local SSD disk
//  scratch_disk {
//  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP

    }
  }

//  metadata = {
//    foo = "bar"
//  }

  metadata_startup_script = "echo hi"

//  service_account {
//    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
//  }

}

output "ip" {
    value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}