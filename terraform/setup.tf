provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}
# Gitlab 
resource "google_compute_instance" "gitlab" {
  name = "gitlab"
  machine_type = "custom-2-8192"
  zone = "${var.region_zone}"
  tags = ["gitlab"]
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }}
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }
  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# Docker e Gitlab-runner
resource "google_compute_instance" "docker" {
  name = "docker"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["docker"]
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }}
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }
  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}
#Regras de firewall para acessar as portas 80 e 443 
resource "google_compute_firewall" "gitlab" {
  name = "tf-www-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"]
}
