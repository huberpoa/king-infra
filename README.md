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
