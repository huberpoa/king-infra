<!-- vim: wrap -->

# Infra ágil

Esse projeto faz parte do desafio [infra-agil](https://github.com/huberpoa/king-infra).

## Qual o objetivo do projeto

Esse projeto visa criar um ambiente seguro e simples para o gerencimento e deploy de aplicações, fornecendo de maneira simples
a configuração de duas máquinas virtuais no Google Cloud Platform, uma máquina serve para execução do Gitlab CE provendo o gerenciamento de versões
e integração continua para a aplicação, e outro servidor para a execução de um ambiente de produção com NGINX realizindo uma conexão de proxy para containers
docker que estão em execução no host.

## Como que a estrutura é criada

As ferramentas que foram utilizadas para a criação da estrutura foram:

- Terraform:

    O Terraform é uma forma muito simples para criar servidores e possui um potencial gigantesco para escalar infraestruturas. Nesse projeto ele é responsável por gerenciar as máquinas que serão criadas no Google Cloud com suas definições padrões.

> terraform plan
> terraform apply

- Ansible:

    Ansible é um gerenciador de configurações simples e poderoso, ele é utilizado nesse projeto para que sejam instaladas todas as depêndencias de compilação, assim como os programas que provem os serviços propostos (gitlab-ce, gitlab-runner, nginx, docker ...)

> ansible-playbook -i hosts  deploy-gitlab.yml -u $REMOTE\_USER -b
> ansible-playbook -i hosts  deploy-production.yml -u $REMOTE\_USER -b

- Gitlab-CE
    
    Gitlab servira para dois própositos, permite que você tenha repositórios armazenados localmente deve uma forma bastante simples, mas também irá servir como a aplicação de CI, a escolha pelo Gitlab é devido a simplicidade que ele proporciona para a configuração de CI.



- NGINX

    Nginx é um servidor com uma configuração bastate simples, performático e com pouco consumo de recursos, por isso a escolha dele para servir de proxy para os containeres do docker.


## Como utilizar a ferramenta

Para utilizar o serviço serão necessários alguns passos iniciais:

- Criar uma conta no GPC.
- Configurar um projeto no GPC
- Realizar o [download](https://cloud.google.com/genomics/downloading-credentials-for-api-access?hl=pt-br) das credenciais de acesso e copiar para a raiz-do-projeto/credentials.json
- Configurar a rede VPC Default com firewall liberando acesso a prota 5555 para todas as VMS.

Após essa configuração precisamos ajustar os arquivos de configuração.

> terraform init
WIP 


TODO: //
Configurar o gitlab-runner no servidor de produção para que o CD funcione corretamente.





