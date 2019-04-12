##
## Use your aws information
provider "aws" {
  region     = "us-east-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key"
}

##
## Inform the name of your existing ssh key
variable "ssh_key_name" {
  default = "you_ssh_key_name"
}
