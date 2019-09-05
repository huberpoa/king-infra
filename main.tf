provider "google" {
    credentials = "${file("${var.mypath}")}"
    region = "${var.region}"
    project = "${var.name-project}"
}

resource "google_compute_instance" "vm_instance" {
    count = 1
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
        command = "echo ${google_compute_instance.vm_instance[count.index].network_interface.access_config.0.nat_ip} >> host"
    }
}

output "private_ip" {
  value = "${google_compute_instance.vm_instance.*.network_interface.0.address}"
}

output "public_ip" {
  value = "${google_compute_instance.vm_instance.*.network_interface.0.access_config.0.nat_ip}"
}


