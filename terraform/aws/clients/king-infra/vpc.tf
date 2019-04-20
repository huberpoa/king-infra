provider "aws" {
  region  = "${var.provider["region"]}"
  profile = "${var.provider["profile"]}"
}

locals {
  common_tags = {
    Name        = "${var.environment}"
    Region      = "${var.region}"
    ClientName  = "${var.client_name}"
    Environment = "${var.environment}"
    AccountName = "${var.account_name}"
    ProjectName = "${var.project_name}"
  }
}

module "vpc" {
  source = "modules/vpc"

  vpc_cidr   = "${var.vpc_cidr}"
  az_public  = "${var.az_public}"

  tags = {
    values = "${local.common_tags}"
  }
}
