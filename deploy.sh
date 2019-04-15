#!/bin/sh
# Limpa máquinas antigas
# Define o usuário que deve ser utilizado pelo ansible,
# Deve ser o mesmo usuário da chave informa na criação do terraform
REMOTE_USER="petry"

 echo '' > hosts
# Impede que o ansible verifique as chaves SSH do destino, em produção deve ser removida essa instrução.
export ANSIBLE_HOST_KEY_CHECKING=False
# Aplica as configurações do terraform
terraform apply -auto-approve
# Garante que anes de iniciar os playbooks o dns do domínio esteja correto
sed -e '1d' -e '2 s/^$/[gitlab]/' -e '4 s/^$/[kubernetes]/' -i hosts
echo "Caso tenha optado por utilizar ssl na configuração do Gitlab,
é extrememante importante que a configuração de DNS do domínio exista e o acesso esteja funcionando corretamente
então para prosseguir, configure no DNS do seu domínio para criar os apontamentos conforme abaixo:"

DOMAIN="$(cat defaults/main.yml | grep -e "gitlab_url: ")"
GITLAB_IP="$(cat hosts | awk 'NR==2')"
echo -e "\n\n"
echo -e "    $DOMAIN -> $GITLAB_IP\"\n"
echo -e "    $(cat defaults/main.yml | grep -e "hostnames: ") -> $(cat hosts | awk 'NR==4')"
echo "Assim que configurar a regra de DNS, digite qualquer tecla para iniciar a instalação e configuração do gitlab"
read -n 1
echo "Testando acesso com o ansible..."


# Valida se todos os servidores estão funcionando corretamente antes de iniciar o playbook
while [[ -z $ANSIBLE_STATUS ]]; do
    ANSIBLE_PING="$(ansible all -m ping -i hosts)"
    # ANSIBLE_STATUS=$("echo $ANSIBLE_PING | cut -d '|' -f 2")
    ANSIBLE_STATUS="$(echo $ANSIBLE_PING | grep SUCCESS)"
    echo "$ANSIBLE_STATUS tentando denovo"
done

# Inicia o playbook de instalação e configuração do gitlab
echo "rodando o ansible para configurar o Gitlab e os Runners"
ansible-playbook -i hosts  deploy-gitlab.yml -u $REMOTE_USER -b

echo "Rodando o ansible para configurar o nginx e ssl"
ansible-playbook -i hosts  deploy-production.yml -u $REMOTE_USER -b
