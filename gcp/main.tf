provider "google" {
  project     = "kubernetes-santzin"
  region      = "us-central1"
}

resource "google_compute_instance" "vm_master_node" {
  name         = "master-node"
  machine_type = "e2-medium"
  zone	       = "us-central1-c"

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("user_data.sh")
  }
}

resource "google_compute_instance" "vm_worker_node" {
  name         = "worker-node"
  machine_type = "e2-medium"
  zone         = "us-central1-c"

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("user_data.sh")
  }
}
