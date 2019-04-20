# Geramos uma chave SSH para apenas ser utilizada na hora
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Chave publica
resource "aws_key_pair" "generated" {
  key_name   = "${var.ssh_key}"
  public_key = "${tls_private_key.generated.public_key_openssh}"
}

locals {
  public_key_filename  = "${var.tls_path}/${var.tls_name}.pub"
  private_key_filename = "${var.tls_path}/${var.tls_name}.pem"
}

resource "local_file" "public_key_openssh" {
  count    = "${var.tls_path != "" ? 1 : 0 }"
  content  = "${tls_private_key.generated.public_key_openssh}"
  filename = "${local.public_key_filename}"
}

resource "local_file" "private_key_pem" {
  count    = "${var.tls_path != "" ? 1 : 0 }"
  content  = "${tls_private_key.generated.private_key_pem}"
  filename = "${local.private_key_filename}"
}

resource "null_resource" "chmod" {
  count      = "${var.tls_path != "" ? 1 : 0 }"
  depends_on = ["local_file.private_key_pem"]

  triggers {
    key = "${tls_private_key.generated.private_key_pem}"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}

output "key_name" {
  value = "${aws_key_pair.generated.key_name}"
}

output "public_key_filepath" {
  value = "${local.public_key_filename}"
}

output "private_key_filepath" {
  value = "${local.private_key_filename}"
}