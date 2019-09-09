variable "region" {
    default = "southamerica-east1"
}

variable "name-project" {}

variable "env" {
    type = "list"
    default = ["gitlab", "production"]
  
}

variable "names-servers" {
    type = "list"
    default = ["gitlab", "web"]
  
}

variable "names" {
  default = "server"
}

variable "machine" {
    default = "n1-standard-2"
}

variable "mypath" {}

variable "image" {
    default = "centos-7"
}

variable "user" {}

variable "pub-key" {}

variable "name-fw" {
    default = "fw"
}

