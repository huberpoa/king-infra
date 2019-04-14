##
## Use your aws information
provider "google" {
  project     = "project-id"
  region      = "region"
  credentials = "your-credentials.json"
}

##
## Inform the name of your existing ssh key
variable "ssh_key_path" {
  default = "rfranzen_king-lab.pub"
}
