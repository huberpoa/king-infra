<!-- vim: wrap 
-->

# Infra ágil

Esse projeto faz parte do desafio [infra-agil](https://github.com/huberpoa/king-infra).

## Qual o objetivo do projeto

Esse projeto visa criar um ambiente seguro e simples para o gerencimento e deploy de aplicações, fornecendo de maneira simples
a configuração de duas máquinas virtuais no Google Cloud Platform, uma máquina serve para execução do Gitlab CE provendo o gerenciamento de versões
e integração continua para a aplicação, e outro servidor para a execução de um ambiente de produção com NGINX realizindo uma conexão de proxy para containeres.
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
    
    Gitlab servira para dois própositos, permite que você tenha repositórios armazenados localmente deve uma forma bastante simples, mas também irá servir como a aplicação de CI, a escolha pelo Gitlab é devido a simplicidade que ele proporciona para a configuração de um pipeline de integração e deploy continuos.

- NGINX

    Nginx é um servidor com uma configuração bastate simples, performático e com pouco consumo de recursos, por isso a escolha dele para servir de proxy para os containeres do docker.

- Dois servidores

    Visando melhorar a performance e criar uma estrutura que permita escalonamento assim como uma gestão mais eficiente dos recursos de infraestrutura, opitei por criar dois servidor.

    Um servidor é responsável pela ferramenta de CI, que como citado anteriormente é o Gitlab, já que além de fornecer uma interface super simples e extremamente eficiente irá gerenciar o versionamento do código.

    E um outro servidor que é responsável por executar os contaires de produção do docker, assim como o nginx que roda no Host e prove a interface de proxy para os containeres.

    Apesar da complexidade adiciona, existe a facilidade para gerenciar novas máquinas e criar um balanceamento, ou até mesmo configurar uma estrutura com um cluster Kubernetes.
## Como utilizar a ferramenta

Para utilizar o serviço serão necessários alguns passos iniciais:

### Requisitos

- Acesso a um registro de domínio com uma zona DNS para a configuração eficiente do SSL.
- Conta no GPC

### Configurações no Google Cloud Platform

- Criar uma conta no GPC.
- Configurar um projeto no GPC
- Realizar o [download](https://cloud.google.com/genomics/downloading-credentials-for-api-access?hl=pt-br) das credenciais de acesso e copiar para a raiz-do-projeto/credentials.json
- Configurar a rede VPC Default com firewall liberando acesso a prota 5555 para todas as VMS.

### Configurações nos arquivos de configuração

- O arquivos de configurações defaults/main.yml
    - gitlab\_runner\_registration\_token: token para criar o runner, isso é informado após a instalação do gitlab no primeiro servidor, e deve ser inserido antes de executar o segundo playbook.
    - gilab\_url: o gitlab será configurado, recomendação em um subdomínio https://lab, é necessário ser informado um protocolo
    - gitlab\_host: host para configuração do registry, recomendação em utilziar um subdomínio lab. Não deve ser informado o protocolo
    - gitlab\_with\_ssl: Configura o let's encrypt durante a execução.
    - nginx\_sites\_enable: é uma lista para com todos os sites que serão criados, o domínio deve existir e apontar para o ip do servidor, as informções que devem ser fornecidas
        - hostnames: list: lista de domínios
        - port: int: Porta que será utilizada para proxy (o container que será utilizado posteriormente **deve** escutar nessa porta)
        - username: string: nome de usuário para ser criado no servidor

    - nginx\_version: versão do nginx, recomendado utilizar nginx-1.15.11
    - nginx\_source\_download: link para o código fonte do nginx, por padrão a url é configurada corretamente.
    - nginx\_install\_dir: pasta onde o nginx será baixado e extraido.
    - letsencrypt\_email: email para informar ao let's encrypt
    

> terraform init

WIP


todo: //

renomear kubernetes -> prod




