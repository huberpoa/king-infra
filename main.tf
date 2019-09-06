provider "google" {
    credentials = "${file("${var.mypath}")}"
    region = "${var.region}"
    project = "${var.name-project}"
}

resource "google_compute_instance" "vm_instance" {
    count = 2

    name = "${var.names}-${count.index + 1}"
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
        command = "echo ${self.name}  ${self.network_interface.0.access_config.0.nat_ip} >> hosts"
    }
}

output "private_ip" {
  value = "${google_compute_instance.vm_instance.*.network_interface.0.network_ip}"
}

output "public_ip" {
  value = "${google_compute_instance.vm_instance.*.network_interface.0.access_config.0.nat_ip}"
}
