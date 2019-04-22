# Provisioning Jenkins VM into AWS  using Terraform and Ansible

## Requirements
* Terraform
* Ansible >= 2.4

## Run provisioning
Run commands within the provisioning folder

    terraform init
    terraform apply -var 'access_key=XXXXXXXXXXXXXXXXXXXX' -var 'secret_key=########################################' -var 'key_name=XXXXXXXXX' -var 'instance_type=XXXXXXXX' -var 'region=XXXXXXX' -var 'private_key=/home/user/.ssh/id_rsa'
    terraform destroy -var 'access_key=XXXXXXXXXXXXXXXXXXXX' -var 'secret_key=########################################' -var 'key_name=XXXXXXXXX' -var 'instance_type=XXXXXXXX' -var 'region=XXXXXXX' -var 'private_key=/home/user/.ssh/id_rsa'
