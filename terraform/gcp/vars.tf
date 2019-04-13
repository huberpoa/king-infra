##
## Use your aws information
provider "google" {
  project     = "kinghost-237418"
  region      = "us-central1"
  credentials = "kinghost-237418-271b55013f11.json"
}

##
## Inform the name of your existing ssh key
variable "ssh_key_path" {
  default = "rfranzen_king-lab.pub"
}
