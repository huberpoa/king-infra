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

# Lista todos os projetos do diretório do terraform
function listProjects() {
    ls -1 ${projects}
}

# Inputs de variáveis
if [ -z "${2}" ] && [ "${1}" != "-h" ]; then
    echo "Passe o nome do projeto, abaixo segue a lista:"

    # Input Field Separator (IFS)
    # Queremos um projeto por linha, como o IFS por padrão é quebra de linha, alteramos o comportamento para ser apenas espaços para obter o resultado desejado.
    IFS=' '

    echo "${bold}${green}$(listProjects)${reset}"
    exit 1
fi

# O segundo parãmetro do script deve ser um projeto que consta no diretório ${projects}
declare projectName="${2}"

# Chave SSH
declare tls_key="/tmp/tls_key.pem"

if [ ! -d "${projects}/${projectName}" ]; then
    echo "${bold}${red}Projeto não encontrado${reset}"

    exit 1
fi

# Entra no diretorio do projeto e cria toda infraestrutura
# Caso não queria realizar auto aprovação, comente -auto-approve
function terraformCreateInfrastructure {
    (
        cd ${projects}/${projectName}

        terraform init
        terraform apply -auto-approve
    )
}

# Entra no diretorio do projeto e faz a remoção total da infraestrutura
function terraformDestroyInfrastructure {
    read -p "Tem certeza que deseja remover TODA infraestrutura?(s/sim): " confirmationDelete
        
    # Perguntamos se realmente deseja realizar esta ação
    if [ "${confirmationDelete}" != "s" ] && [ "${confirmationDelete}" != "sim" ]; then
        echo "Opção inválida, saindo"

        exit 1
    fi

    (
        cd ${projects}/${projectName}

        terraform destroy -auto-approve
    )
}

function ansibleGetHost() {
    declare whatInformation="${1}"
    declare kindInformarion="${whatInformation:=aws_instance_public_dns}"

    if [ "${kindInformarion}" == "ip" ]; then
        declare kindInformarion="aws_instance_ip"
    fi

    (
        cd ${projects}/${projectName}

        echo "$(terraform output | grep ${kindInformarion} | sed 's| ||g' | cut -d "=" -f2)"
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
    declare publicDns="$(ansibleGetHost)"

    (
        cd ${pathAnsible}

        ansible-playbook -i hosts \
        --private-key=/tmp/tls_key.pem \
        --extra-vars gitlab_public_url=${publicDns} \
        --extra-vars gitlab_external_url=https://${publicDns} \
        site.yml
    )
}

function terraformOutput {
    (
        cd ${projects}/${projectName}

        terraform output
    )
}

function showInformations() {
cat <<EOT
 IP: $(ansibleGetHost ip)
URL: https://$(ansibleGetHost)
SSH: ssh ubuntu@$(ansibleGetHost) -i ${tls_key}
EOT
}

function help() {
cat <<EOT
Opções disponíveis:
-go                        Cria infraestrutura com Terraform, faz teste com Ansible para
                           verificar se host está em funcionamento e roda Ansible playbook.
-ar | --ansibleRunSite     Roda playbook do Ansible.
-tc | --terraformCreate    Criar toda infraestrutura com Terraform.
-to | --terraformOutput    Mostra informações geradas pelo Terraform.
-td | --terraformDestroy   Destroy toda infraestrutuea com Terraform. Necessário confirmação.
-rc | --recreate           Utiliza opções -td e -go
-si | --showInformations   Mostra informações parseadas do Terraform
EOT
}

# O primeiro parãmetro deve ser algum abaixo.
case "$1" in
    -go )
    bash $0 -tc $2
    echo; echo "Espere um momento..."; sleep 10

    ansibleTestSite
    bash $0 -ar $2    
    ;;

    -ar | --ansibleRunSite ) 
    ansibleRunSite
    
    bash $0 -si $2
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

    -rc | --recreate )
    bash $0 -td $2
    bash $0 -go $2
    ;;

    -si | --showInformations )
    showInformations
    ;;

    -h | --help )
    help
    ;;
esac