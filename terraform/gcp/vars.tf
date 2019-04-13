##
## Use your aws information
provider "google" {
  project     = "your_id"
  region      = "region"
  credentials = "your_file.json"
}

##
## Inform the name of your existing ssh key
variable "ssh_key_path" {
  default = "rfranzen_king-lab.pub"
}
