provider "google" {
    credentials = "${file("${var.mypath}")}"
    region = "${var.region}"
    project = "${var.name-project}"
}
