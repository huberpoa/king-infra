##
## Use your aws information
provider "google" {
  project     = "project-name"
  region      = "region"
  credentials = "credentialfile.json"
}

##
## Inform the name of your existing ssh key
variable "ssh_key_path" {
  #default = "you_ssh_key_path"
}
