variable "instance_type" {
  type        = "string"
  description = "Instance type - t2.micro"
  default     = "t2.micro"
}

variable "vpc_cidr" {
  type        = "string"
  description = "The CIDR block of the VPC"
}

variable "az_public" {
  type = "list"
}

variable "tags" {
  type = "map"
}
