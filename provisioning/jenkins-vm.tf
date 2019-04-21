provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Resource configuration
resource "aws_security_group" "desafio-kinghost" {
  name = "desafio-kinghost"
  description = "Desafio KingHost Security Group"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resource configuration
resource "aws_instance" "desafio-kinghost" {
  ami = "ami-0b500ef59d8335eee"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.desafio-kinghost.name}"]
  tags {
    Name = "desafio-kinghost"
  }

  provisioner "remote-exec" {
    inline = [ "sudo yum -y install python" ]
 
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key '${var.private_key}' playbook.yml --ssh-common-args='-o StrictHostKeyChecking=no'" 
  }
}
