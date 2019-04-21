# Divertindo-se com Infra as Code - Desafio Prático

## Objetivo do projeto


## Soluções adotadas
### Cloud Provider (AWS)

### Infraestrutura como código (Terraform)

### Gerenciamento de configuração (Ansible)

### Integração e entrega contínua (Gitlab CI/CD)
[https://docs.gitlab.com/ee/install/relative_url.html](https://docs.gitlab.com/ee/install/relative_url.html)

## Pré requisitos

Ter `Ansible` instalado na máquina, caso não tenha, podemos utilizar diretamente de um container [https://github.com/raffaeldutra/docker-ansible](https://github.com/raffaeldutra/docker-ansible)


## Como fazer o deploy da infraestrutura

Todo o deploy se encontra no script `runme.sh`.

### Como utilizar o script

Este script necessita dois parãmetros.
* Ação
* Nome do cliente

Simplesmente execute `bash runme.sh` e verifique a saída.