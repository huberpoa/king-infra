instance_type = "t2.medium"
region        = "us-east-1"
environment   = "production"
client_name   = "king-infra"
account_name  = "king-infra"
project_name  = "king-infra-challenge"

provider = {
    region  = "us-east-1"
    profile = "king-infra"
}

vpc_cidr = "172.16.0.0/16"

az_public = [
    {
        name = "public"
        az   = "us-east-1a"
        cidr = "172.16.1.0/24"
    },
    {
        name = "public"
        az   = "us-east-1b"
        cidr = "172.16.3.0/24"
    }
]