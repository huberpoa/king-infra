##
## Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

##
## Define firewall rules
resource "google_compute_firewall" "default" {
  name    = "sandbox-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  source_tags   = ["web", "sandbox"]
}

##
## Define network
#resource "google_compute_network" "default" {
#  name = "default"
#}

##
## Define the vps using latest Ubuntu LTS 18.04
resource "google_compute_instance" "vm_instance" {
  name         = "sandbox-${random_id.instance_id.hex}"
  #machine_type = "f1-micro"
  machine_type = "g1-small"
  #machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata_startup_script = "sudo apt update && sudo apt install python python-apt -y"
  metadata {
    sshKeys = "ubuntu:${file("${var.ssh_key_path}")}"
  }

  network_interface {
    network = "default"

    access_config {
    }
  }
}
