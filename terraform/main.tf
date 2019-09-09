provider "google" {
    credentials = "${file("${var.mypath}")}"
    region = "${var.region}"
    project = "${var.name-project}"
}

resource "google_compute_firewall" "default" {
    name = "${var.name-fw}"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22", "80", "443", "5000"]
    }
}

resource "google_compute_instance" "vm_instance" {
    count = 2

    name = "${var.names-servers[count.index]}-${var.names}"
    machine_type = "${var.machine}"
    zone = "${var.region}-a"

    metadata = {
        sshKeys = "${var.user}:${file("${var.pub-key}")}"
    }

    boot_disk {
        initialize_params {
            image = "${var.image}"
        }
    }

    network_interface {
        network = "default"
        access_config {}
    }

    provisioner "local-exec" {
        command = "echo '[${var.env[count.index]}]\n${self.network_interface.0.access_config.0.nat_ip}  'ansible_ssh_user=$USER >> hosts"
    }
}

output "public_ip" {
  value = "${google_compute_instance.vm_instance.name} ${google_compute_instance.vm_instance.*.network_interface.0.access_config.0.nat_ip}"
}
