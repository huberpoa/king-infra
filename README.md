<!-- vim: wrap 
-->

# Infra ágil

Esse projeto faz parte do desafio [infra-agil](https://github.com/huberpoa/king-infra).

## Qual o objetivo do projeto

Esse projeto visa criar um ambiente seguro e simples para o gerencimento e deploy de aplicações, fornecendo de maneira eficiente
para configuração de duas máquinas virtuais no Google Cloud Platform.

## Como que a estrutura é criada

- Dois servidores

    Visando melhorar a performance e criar uma estrutura que permita escalonamentos de maneira mais simples, assim como uma gestão eficiente dos recursos de infraestrutura, opitei por criar dois servidor.

    Um servidor é responsável pela ferramenta de CI, que é o Gitlab, já que além de fornecer uma interface super simples e extremamente eficiente irá gerenciar o versionamento do código.

    E um outro servidor que é responsável por executar os contaires de produção do docker, assim como o nginx que roda no Host e prove a proxy para cada um dos containeres.

    Apesar da complexidade que essa configuração oferece, existe a facilidade para gerenciar novas máquinas e implementar novas máquinas para o balanceamento, ou até mesmo configurar uma nova estrutura com um cluster Kubernetes.


As ferramentas que foram utilizadas para a criação da estrutura foram:

- Terraform:

    O Terraform é uma forma muito simples para criar servidores e possui um potencial gigantesco para escalar infraestruturas. Nesse projeto ele é responsável por gerenciar as máquinas que serão criadas no Google Cloud com suas definições padrões.

- Ansible:

    Ansible é um gerenciador de configurações simples e poderoso, ele é utilizado nesse projeto para que sejam instaladas todas as depêndencias de compilação, assim como os programas que provem os serviços propostos (gitlab-ce, gitlab-runner, nginx, docker ...)

- Gitlab-CE
    
    Gitlab servira para dois própositos, permite que você tenha repositórios armazenados localmente deve uma forma bastante simples, mas também irá servir como a aplicação de CI, a escolha pelo Gitlab é devido a simplicidade que ele proporciona para a configuração de um pipeline de integração e deploy continuos.

- NGINX

    Nginx é um servidor com uma configuração bastate simples, performático e com pouco consumo de recursos, por isso a escolha dele para servir de proxy para os containeres do docker.

# Como utilizar a ferramenta

Para utilizar o serviço serão necessários alguns passos iniciais:

## Requisitos

- Acesso a um registro de domínio com uma zona DNS para a configuração eficiente do SSL.
- Conta no GPC

## Configurações no Google Cloud Platform

- Criar uma conta no GPC.
- Configurar um projeto no GPC
- Navegue até [Instâncias de VM](https://console.cloud.google.com/compute/instances) e valide se a instância da vm já está configurada
- Realizar o [download](https://console.cloud.google.com/apis/credentials) das credenciais de acesso e copiar para a raiz-do-projeto/credentials.json

## Configurações nos arquivos de configuração do ansible

Copia o arquivo defaults/main.yml.example para defaults/main.yml e altere as informações, conforme abaixo:

- O arquivos de configurações defaults/main.yml
    - gitlab\_runner\_registration\_token, token para criar o runner, isso é informado após a instalação do gitlab no primeiro servidor, e deve ser inserido antes de executar o segundo playbook.
    - gilab\_url, o gitlab será configurado, recomendação em um subdomínio https://lab, é necessário ser informado um protocolo
    - gitlab\_host, host para configuração do registry, recomendação em utilziar um subdomínio lab. Não deve ser informado o protocolo
    - gitlab\_with\_ssl, Configura o let's encrypt durante a execução.
    - nginx\_sites\_enable, é uma lista para com todos os sites que serão criados, o domínio deve existir e apontar para o ip do servidor, as informções que devem ser fornecidas
        - hostnames, lista de domínios
        - port, número Porta que será utilizada para proxy (o container que será utilizado posteriormente **deve** escutar nessa porta)
        - username, nome de usuário para ser criado no servidor

    - nginx\_version, versão do nginx, recomendado utilizar nginx-1.15.11
    - nginx\_source\_download, link para o código fonte do nginx, por padrão a url é configurada corretamente.
    - nginx\_install\_dir, pasta onde o nginx será baixado e extraido.
    - letsencrypt\_email, email para informar ao let's encrypt
    
    A configuração recomenda, subdomínios lab. e site., assim como o uso das portas 1234 para o nginx e 5555 para o registry, se adequam ao projeto de ajuda [nginx-fpm-docker](https://github.com/gabrielpetry/nginx-fpm-docker) que é usado como base no gitlab, para fins de exemplo do funcionamento.

## Configurações nos arquivos de configuração do terraform

Copie o arquivo deploy-gpc.tf.example para deploy-gpc.tf e configure as seguintes configuraçẽos:
- ssh-key, informe o seu usuário atual da máquina, assim como o caminho para o arquivo da sua chave publica.

Copie o arquivo provider.tf.example para provider.tf e ajuste as seguintes configurações:
- project, informe o nome do projeto que você criou no google
- region, configure a região onde o servidor será alocado
- zone, configure a zona onde o servidor será alocado.

# Tudo configurado, como começar?

1. Precisamos instalar as dependências do terraform com o comando,

> terraform init

1. Agora podemos usar o `terraform plan` para validar se está tudo funcionando corretamente

1. Se estiver tudo funcionando corretamente, podemos iniciar o script interativo para deploy.

> ./deploy.sh

1. Assim que o terraform terminar de criar as instâncias no GPC, será exibida uma tela para que sejam configuradas as entradas de DNS, é importante que essas entradas estejam funcionando corretamente, já que o comportamento padrão da instação é configurar o let's encrypt. 

1. Quando a instalação do gitlab for concluida o script irá aguardar a configuração de um repositório 

    1.1 Para configurar o repositório, será necessário:

        1.1 Acessar a url de instalação do gitlab e informar uma nova senha de root.

        1.1 Em seguida é necessário logar no gitlab com o usuário root e a senha que acabou de configurar.

        1.1 Criar um novo projeto, a fim de facilitar os testes pode-se importar o projeto que se encontra nesse repositório https://github.com/gabrielpetry/nginx-fpm-docker, e utilizar o slug e nome do repositório como **app**, utilize a opção importar -> Repo by URL

        1.1 Após criar o repositório deve ser acessado o caminho /root/app/settings/ci_cd e anotar o token de registro do runner.

        1.1 Inserir o token de registro do runner na variavél WIP gitlab_runner_registration_token

1. Quando concluir a configuração do token em defaults/main.yml basta prescionar alguma tecla para dar seguimento no execução do script.

1. Quando o script terminar de executar estará configurado o nginx e realizando o proxy para a porta 1234.

1. Então podemos ir até o repositório do gitlab e editar o arquivo .gitlab-ci.yml, informando as variaveis corretas
    1. REGISTRY: "vhost\_gitlab:5555"
    1. IMAGE\_NAME: "app"
    1. IMAGE: vhost\_gitlab:5555/root/app
    1. PORT: "1234"

1. Se tudo correu bem, um novo pipeline será executado sem erros e a aplicação estará acessível no host do nginx ;) 


Dúvidas contato@gabrielpetry.com.br




