<<<<<<< HEAD
# Desafio Kinghost
## Execução
### Pré-configuração
**Todo o cenário foi desenvolvido e testado utilizando o Gitlab e GCP.**

#### Terraform
Editar o arquivo *terraform/gcp/vars.tf* informando seus dados para a criançao
 do ambiente.

Depois o script build_environment.sh pode ser executado para o setup do
 ambiente.


#### Aplicação
Para este desafio, parti de um princípio que a aplicação fica em um repositório
 diferente. Nos meus testes criei um repositório público no gitlab com um
 arquivo simples em PHP:
```
<?php phpinfo(); ?>
```

Não encontrei uma forma simples e dinâmica para disparar a ação automática no
 servidor de aplicação, portanto é necessário inserir o endereço do servidor no
 arquivo .gitlab-ci.yml (identificado como "IP_DO_SERVIDOR_AQUI")
```
stages:
  - deploy

deploy_application:
  stage: deploy
  script: "curl -i -X POST -H 'Content-type: application/json' -d '{\"token\": \"NDkyMTNlY2ZWYwYWZmOGExMGRjZGY0MjQyNTQxNGYxRhZjVhNzNlZDVlNTJmYjE4\"}' http://IP_DO_SERVIDOR_AQUI:9088/hooks/build-environment"
  only:
    - master
```
Assim, a cada commit no branch master da aplicação, o webhook será chamado, ele
 vai fazer um pull no repositório e criar um novo container com a nova versão.

Optei por não utilizar um repositório fechado e deixar a pré-configuração ainda
 mais complexa por conta das chaves.

Depois que vocês criarem este repositório, o endereço do mesmo deverá ser
 inserido em: *ansible/roles/app/tasks/main.yml* na linha **40**.


#### Ansible
Depois de ter o endereço IP ou DNS do seu servidor, a informação deverá ser
 adicionada aos hosts do Ansible no arquivo **ansible/production**

Agora é possível dar inicio à configuração do servidor.
```
cd ansible
ansible-playbook -i production site.yml --private-key=../terraform/gcp/rfranzen_king-lab
```

Pronto, depois que o Ansible finalizar a execução é só acessar o servidor via http ou https.


## Ferramentas
### Terraform
Nenhuma configuração excepcional foi feita no Terraform, apenas o padrão para a
 criação do ambiente.

### Ansible
Foi utilizado uma role de um terceiro para a instalação do Docker no Ansible:
 https://github.com/geerlingguy/ansible-role-docker

### Docker
O Docker-compose foi utilizado para a definição dos containers.


## Decisões
### ANSIBLE
A proposta do desafio acaba forçando o ambiente para um caminho muito específico
 e, ao meu ver, não sendo a solução ideal, porém foi um desafio interessante.
 Nunca havia precisado implementar nada utilizando o Ansible e creio ter sido um
 aprendizado interessante.

Acredito que o Ansible não seja a melhor opção, visto que o uso de Playbooks
 não assegura constantemente o estado do ambiente, diferentemente de uma
 gerência utilizando o Puppet que garante constantemente que o estado da
 máquina será aquele que foi definido no código.

Ainda faço um adendo em relação à esta minha primeira experiência com o ansible;
 Achei a execução dele extremamente lenta. Talvez pelo fato de eu não conhecer
 muito bem a ferramenta, não tenha explorado totalmente as opções disponíveis
 para customização e otimização.

Também não sinto que consegui montar um cenário que seja escalável da forma que
 eu gostaria. Este cenário sim, atende à proposta do desafio, porém eu ficaria
 mais satisfeito com algo que pudesse ser expandido para cenários diferentes
 com mais facilidade.

### TERRAFORM
Comecei o projeto pensando em utilizar a AWS visto que já tinha familiaridade
 com o ambiente, inclusive já havia feito testes com o Terraform lá, porém meus
 365 dias de uso já haviam expirado e para não criar outra conta, optei pela
 possibilidade de conhecer o GCP (nunca havia usado antes). Por isso há
 configurações para os dois ambientes, mas todo cenário foi validado apenas
 no Google.

### NGINX
No container do NGINX optei por mapear externamente os arquivos de configuração
(/opt/nginx/conf.d) pensando em um cenário onde o servidor poderia receber
outros vhosts facilmente e sem a necessidade de modificações no compose.

Também não segui exatamente o cenário que pedia que o container de aplicação
 fosse composto por um webserver e o php-fpm. Deixei este container apenas com o
 php-fpm visto que neste cenário não se faz necessário o webserver.
=======
# Divertindo-se com Infra as Code - Desafio Prático

## O que é?

Este projeto faz parte do processo seletivo para o cargo de Analista de Infraestrutura Ágil da KingHost. :)

Este desafio foi projetado a fim de medir seu nível de conhecimento com tecnologias DevOps e players de cloud pública, e suas capacidades de propor novas ideias e arquiteturas para nossos serviços, sempre com o foco de manter os ambientes seguros.

## Introdução

Um de nossos projetos internos necessita de um novo ambiente que permita desenvolvimento e deploy de forma automatizada e contínua. Para isto, você, no papel de Analista de Infraestrutura Ágil, foi chamado para elaborar uma infraestrutura a fim de atender a esta demanda dos times de desenvolvimento.

Para isto, foram estipuladas algumas necessidades, as quais devem ser atendidas:

* A infraestrutura deverá ser provisionada na AWS ou GCP usando ferramenta de gerenciamento de infraestrutura como código, sem utilização de ferramentas próprias desses players (crie uma conta gratuita para prosseguir);
* Deverá ser instalada e configurada uma ferramenta de CI/CD de sua preferência usando ferramentas de automação de IT;
* Deverá ser criado um pipeline de push deploy dentro da ferramenta de CI/CD, a qual será responsável por reconstruir a imagem em caso de alterações em seus requisitos e publicá-la no servidor de produção, e;
* **(Extra)** Toda arquitetura deverá ser disponibilizada através da execução de um simples shell script.

A principal ideia aqui é que você **faça por você mesmo (DIY)**.
	
## Requisitos técnicos

Para realização deste desafio, deverão ser observados os seguintes requisitos:

* A aplicação deverá ser hospedada em ambiente conteinerizado, com os seguintes requisitos:
	* A imagem deve partir de um sistema operacional limpo (Ubuntu ou Alpine), sem adicionais instalados;
	* Nessa imagem, deverá executar um web server + PHP-FPM, e a aplicação deverá ser hospedada em /home/app;
* A máquina onde rodará a aplicação deverá conter um web server Nginx, o qual se comunicará com o container via proxy, e deverá escutar nas portas 80 e 443;
* A infraestrutura proposta deverá contemplar a possibilidade de utilização por múltiplos projetos, e;
* Obviamente, todo o código da infraestrutura deve estar versionado. :)
	
As configurações devem, sempre, prezar pelas boas práticas de segurança, com principal atenção aos seguintes pontos:

* O acesso aos servidores deverá ser possível apenas utilizando chave SSH;
* O repositório não deverá contar com nenhum arquivo que possua dados sensíveis **(caráter eliminatório)**;
* Priorizar sempre o acesso HTTPS (o certificado poderá ser auto-assinado para fins do desafio).

Documentação é primordial! Então, priorize os comentários em seu código sempre que possível. :)

## Por onde começar?

Para ajudá-lo em sua jornada, abaixo tem algumas fontes de documentação que você poderá utilizar, caso não saibas por onde iniciar.

* https://github.com/terraform-providers
* https://github.com/ansible/ansible-examples
* https://hub.docker.com/

Você tem alguma dúvida? Você pode enviar um e-mail para alessandro.santos@kinghost.com.br a qualquer momento, que iremos o mais breve possível retorná-lo. ;)
	
## Entregáveis

Ao final do desafio, você deverá realizar um "pull request" neste repositório, o qual deverá conter o seguinte conteúdo:

* Todo e qualquer arquivo necessário para que possamos reproduzir a infra criada em nossas contas nos players supracitados, e;
* Arquivo README.md, contendo:
	* Instruções de como executar a infraestrutura entregue;
	* Ferramentas utilizadas, e o por que estas foram escolhidas para a realização do desafio, e;
	* Decisões adotadas durante o planejamento e execução do desafio, justificando-as.

**IMPORTANTE: Mesmo que você não consiga concluir o desafio por completo, envie o que você conseguiu fazer!** Iremos avaliar todo e qualquer desenvolvimento que você nos apresentar! O mais importante deste desafio é, que ao final dele, você adquira novos conhecimentos ou aprimore os que você já possui. ;)

Após, envie e-mail para o e-mail nicole.santos@kinghost.com.br, com cópia para alessandro.santos@kinghost.com.br e douglas@kinghost.com.br, com o assunto **"Desafio Prático Infraestrutura Ágil"**, sinalizando a entrega do desafio para avaliação.

## Prazo para conclusão

Está informado no e-mail enviado junto com o endereço deste desafio.

## O que será avaliado?

* Flexibilidade
* Maneira como você está entregando este desafio
* Capacidade de tomada de decisões técnicas
* Complexidade
	
**Good luck and having fun! ;)**
>>>>>>> 3bef5f2b9c417e79cc6706e0a0e5022a8e77fe6e
