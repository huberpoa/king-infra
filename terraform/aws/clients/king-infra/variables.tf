variable "provider" {
  type = "map"

  default = {
    region  = "us-east-1"
    profile = "king-infra"
  }
}

variable "vpc_cidr" {
  type = "string"
}

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "tls_name" {
  description = "Name use to generate private key"
  type = "string"
  default = "tls_key"
}

variable "tls_path" {
  description = "Path to a directory where the public and private key will be stored"
  type = "string"
  default = "/tmp"
}

variable "ssh_key" {
  type    = "string"
  default = "king-infra"
}

# Tags
variable "region" {
  type        = "string"
  description = "The region used for this project"
}

variable "az_public" {
  type        = "list"
  description = "The public availability zone used for this project"
}

variable "client_name" {
  type        = "string"
  description = "Client owner for this project"
}

variable "environment" {
  type        = "string"
  description = "The default environment"
}

variable "account_name" {
  type        = "string"
  description = "The account name used for this project"
}

variable "project_name" {
  type        = "string"
  description = "Project name"
}
