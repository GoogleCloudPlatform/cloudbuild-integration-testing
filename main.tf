provider "google" {
  project     = "${var.project-name}"
  region      = "${var.region}"
}

// Create a new instance
resource "google_compute_instance" "default" {
  // strip underscores from provided name b/c GCE doesn't like them
  name         = "${replace(var.instance-name,"_","")}"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"

  tags = ["allow-8080", "allow-3000", "allow-k8s-nodeports"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      // image = "microk8s-from-instance-01"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // An Ephemeral IP will be assigned
    }
  }

  // startup:
  // 1. install microk8s
    // (using a custom microk8s; see https://github.com/GoogleCloudPlatform/cloudbuild-integration-testing/issues/36)
  // 2. program instance for self-deletion
  // TODO: bake an image where all this is already done
  metadata = {
    startup-script = <<-SCRIPT
    snap install microk8s --classic
    # Patch microk8s configuration so we can connect from the outside
    # This is not a good practice, use it only for the purpose of this lab
    sed -i.sed-bak "s/127\.0\.0\.1/0.0.0.0/" /var/snap/microk8s/current/args/kube-apiserver
    systemctl restart snap.microk8s.daemon-apiserver.service
    microk8s.status --wait-ready
    microk8s.enable dns
    microk8s.status --wait-ready
    echo "gcloud compute instances delete $(hostname) --zone $(curl -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/zone -s | cut -d/ -f4) -q" | at Now + ${var.self-destruct-timeout-minutes} Minutes
    SCRIPT
  }

  service_account {
    scopes = [
      // default GCE scopes
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      // grant permission to compute API so this instance can delete itself
      "https://www.googleapis.com/auth/compute",
      ]
  }

}

output "ip" {
    value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
