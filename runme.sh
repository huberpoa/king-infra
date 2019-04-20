#!/usr/bin/env bash

# Terminal colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)
bold=$(tput bold)

# Se o sistema for Microsoft, saimos do script
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "${bold}${red}Sistema não suportado para este script, saindo...${reset}"

    exit 1
fi

# Terraform Variable
declare pathTerraform="terraform"
declare projects=${pathTerraform}/aws/clients

# Ansible variables
declare pathAnsible="ansible"

function listProjects() {
    ls -1 ${projects}
}

# Inputs de variáveis
if [ -z "${2}" ]; then
    echo "Passe o nome do projeto, abaixo segue a lista:"

    IFS=' '

    echo "${bold}${green}$(listProjects)${reset}"
    exit 1
fi

declare projectName="${2}"

# Chave SSH
declare tls_key="/tmp/tls_key.pem"

if [ ! -d "${projects}/${project}" ]; then
    echo "${bold}${red}Projeto não encontrado${reset}"

    exit 1
fi

# Entra no diretorio do projeto e cria toda infraestrutura
function terraformCreateInfrastructure {
    (
        cd ${projects}/${projectName}

        terraform init
        terraform apply -auto-approve
    )
}

# Entra no diretorio do projeto e faz a remoção total da infraestrutura
function terraformDestroyInfrastructure {
    (
        cd ${projects}/${projectName}

        terraform destroy -auto-approve
    )
}

function ansibleGetHost() {
    (
        cd ${projects}/${projectName}

        echo "$(terraform output | grep aws_instance_public_dns | sed 's| ||g' | cut -d "=" -f2)"
    )

}

function ansibleTestSite() {
cat <<EOT > ${pathAnsible}/hosts
[king-infra]
$(ansibleGetHost)

[king-infra:vars]
ansible_python_interpreter=/usr/bin/python3
EOT

    (
        cd ${pathAnsible}

        ansible -i hosts \
        -m ping king-infra \
        --private-key=${tls_key}
    )
}

function ansibleRunSite() {
    declare machine="$(ansibleGetHost)"

    (
        cd ${pathAnsible}

        ansible-playbook -i hosts \
        --private-key=/tmp/tls_key.pem \
        --extra-vars gitlab_external_url=http://${machine} \
        site.yml
    )
}

function terraformOutput {
    terraform output
}

case "$1" in
    -go ) 
    terraformCreateInfrastructure

    ansibleTestSite
    ansibleRunSite
    ;;

    -tc | --terraformCreate ) 
    terraformCreateInfrastructure
    ;;

    -to | --terraformOutput ) 
    terraformOutput
    ;;

    -td | --terraformDestroy )
    terraformDestroyInfrastructure
    ;;
esac