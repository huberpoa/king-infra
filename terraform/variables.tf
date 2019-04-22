variable "region" {
  default = "us-east1"
}

variable "region_zone" {
  default = "us-east1-b"
}

variable "project_name" {
  description = "Nome do projeto para construir as VM"
}

variable "credentials_file_path" {
  description = "Credenciais do GCP"
  default = "google-account.json"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default = "~/.ssh/gcloud_id_rsa.pub"
}