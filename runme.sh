#!/usr/bin/env bash
# Rafael Dutra <raffaeldutra@gmail.com>

set -o errexit   # paramos o script em caso de problemas
set -o pipefail  # falhamos em caso de uma saída de comando conter erros

function help() {
cat <<EOT

Opções disponíveis:
-go                          Cria infraestrutura com Terraform, faz teste com Ansible para
                             verificar se host está em funcionamento e roda Ansible playbook.
-ae | --ansibleRequirements  Instala os requirements para Ansible.
-ar | --ansibleRunSite       Roda playbook do Ansible.
-tc | --terraformCreate      Criar toda infraestrutura com Terraform.
-to | --terraformOutput      Mostra informações geradas pelo Terraform.
-td | --terraformDestroy     Destroy toda infraestrutuea com Terraform. Necessário confirmação.
-rc | --recreate             Utiliza opções -td e -go
-si | --showInformations     Mostra informações parseadas do Terraform
-cn | --clientNames          Lista os clientes.
EOT
}

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

# AWS credentials
declare pathAWS="${HOME}/.aws"
declare AWSCredentials="${pathAWS}/credentials"

# Terraform Variable
declare pathTerraform="terraform"
declare projects=${pathTerraform}/aws/clients

# Ansible variables
declare pathAnsible="ansible"

# Lista todos os projetos do diretório do terraform
function listProjects() {
    ls -1 ${projects}
}

# Faz teste de argumentos passados pela linha de comando
# Em caso do primeiro parâmetro for igual a -h ou -cn, não é necessário o nome do cliente
if [ -z "${2}" ] && [ "${1}" != "-h" ] && [ "${1}" != "-cn" ]; then
    echo "Utilização: bash $0 [OPÇÃO] [NOME DO CLIENTE]"

    help

    # Input Field Separator (IFS)
    # Queremos um projeto por linha, como o IFS por padrão é quebra de linha, alteramos o comportamento para ser apenas espaços para obter o resultado desejado.
    IFS=' '

    echo; echo "Clientes disponíveis no momento: "
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

# Roda o comando do Galaxy para Ansible automaticamente
function ansibleRequirements() {
    (
        cd ${pathAnsible}

        ansible-galaxy install -r requirements.yml
    )
}

# Retorna informações gerada a partir do terraform output
# Por default retorna a informação de DNS pública da AWS
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

# Gera em tempo real o arquivo de configuração de hosts para o Ansible
# Uma vez gerada o arquivo, será feito um teste de ping neste host, caso
# O ping retorne falso, espera mais alguns segundos para tentar novamente
# em caso de 3 falhas consecutivas, o processo do Ansible é parado 
function ansibleTestSite() {
cat <<EOT > ${pathAnsible}/hosts
[king-infra]
$(ansibleGetHost)

[king-infra:vars]
ansible_python_interpreter=/usr/bin/python3
EOT

    declare try=1
    while [ $try -ne 3 ]
    do
        (
            cd ${pathAnsible}

            ansible -i hosts \
            -m ping king-infra \
            --private-key=${tls_key}
        )

        if [ $? -eq 0 ]; then
            try=3
        elif [ $try -eq 3 ]; then
           echo "Não foi possível realizar o ping no host $(ansibleGetHost), saindo..."
           
           exit 1
        else
            try=$[$try+1]
        fi
    done
}

# Roda o playbook definido no site.yml
# O papel principal dessa função é passar argumentos para o Ansible, pois dela que todo provisionamento é realizado
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

# Retorna o output do terraform
function terraformOutput {
    (
        cd ${projects}/${projectName}

        terraform output
    )
}

# Mostra informações finais no terminal
function showInformations() {
cat <<EOT
 IP: $(ansibleGetHost ip)
URL: https://$(ansibleGetHost)
SSH: ssh ubuntu@$(ansibleGetHost) -i ${tls_key}
EOT
}

# Verifica se o arquivo terraform.tfstate está presente no ambiente, pois pode falhar com alguns argumentos do script, como por exemplo a tentativa de rodar ansible sem mesmo ter uma infra mínima rodando
function terraformPresence() {
    if [ ! -f "${projects}/${projectName}/terraform.tfstate" ]; then
        echo "Não existe uma infraestrutura mínima no momento"
        echo "Rode o comando ${bold}${green}bash $0 -tc <nome do cliente>${reset} primeiro"

        exit 1
    fi
}

# Controle de credenciais da AWS
# Falha em caso de não encontra o arquivo com credenciais ou se não conter a credencial correta para utilizar na AWS
function awsCheckCredentials() {
    cat ${AWSCredentials} | grep "${projectName}"

    echo $? && credentialsFound=0 || credentialsFound=1

    if [ ! -f "${AWSCredentials}" ] || [ ${credentialsFound} -ne 0 ]; then
        echo "Arquivo ${AWSCredentials} não encontrado ou credencial não encontrada, saindo..."

        exit 1
    fi
}

# O primeiro parãmetro deve ser algum abaixo.
case "$1" in
    -go )
    awsCheckCredentials
    bash $0 -tc $2
    echo; echo "Espere um momento..."
    sleep 10

    ansibleTestSite
    bash $0 -ar $2
    ;;

    -ar | --ansibleRunSite )
    terraformPresence

    bash $0 -ae $2
    ansibleRunSite
    
    bash $0 -si $2
    ;;

    -ae | --ansibleRequirements )
    ansibleRequirements
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
    terraformPresence
    showInformations
    ;;

    -cn | --clientNames )
    IFS=' '

    echo "Lista de clientes: "
    echo "${yellow}${bold}$(listProjects)${reset}"
    ;;

    -h | --help )
    help
    ;;
*) help
esac
