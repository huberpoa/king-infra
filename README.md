# Divertindo-se com Infra as Code - Desafio Prático

## Pré requisitos
Ter `Ansible` instalado na máquina, caso não tenha, podemos utilizar diretamente de um container [https://github.com/raffaeldutra/docker-ansible](https://github.com/raffaeldutra/docker-ansible).

## Objetivo do projeto
Utilizar infraestrura como código de uma maneira simplificada onde tudo é basicamente controlado via script e automatizado por ele.

A infraestrutura fica hospedada na AWS sendo facilmente possível reconstruir toda o ambiente do zero.

Pensando em trazer o máximo de automação possível dentro do contexto que foi solicitado, segui na linha onde o meu endpoint (public dns) da AWS seria o ponto de entrada para toda a configuração com Ansible.

Ao final, cada ferramenta foi escolhida principalmente pelos seguintes motivos:

* Simplicidade
* Menor dependência possível, como agentes (Puppet) ou instalação de ferramentas adicionais (Ruby/Java).
* Documentação

## Soluções adotadas
### Cloud Provider (AWS)
Utilizado AWS devido a praticidade de utilizar recursos com Terraform e pelo maior contato que tenho com ela e o tempo para realizar o teste.

### Infraestrutura como código (Terraform)
Terraform é a escolha principal para trazer uma infraestrutura do zero e o maior motivo de utilizar esta ferramenta é a facilidade de consumir recursos de Cloud Providers, como AWS.

### Gerenciamento de configuração (Ansible)
Praticamente qualquer OS Linux vem com Python instalado e a única coisa que precisamos fazer é configurar o host e chaves.

A grande decisão de utilizar Ansible ou não é pela fácil implementação que ela proporciona, basta SSH e Python e você irá fazer automação de processos/tarefas.

Para instalar Docker com Ansible, eu utilizei uma `role` desenvolvida por mim que pode ser encontrada em [https://galaxy.ansible.com/raffaeldutra/ansible_docker_role](https://galaxy.ansible.com/raffaeldutra/ansible_docker_role)

### Serviço Web (Nginx)
Nginx tem inúmeras funcionalidades, como proxy reverso para email, balanceador de carga para http, tcp,udp e baixo consumo de memória ram. Também uma sintaxe mais simples ao meu ver que Apache.

### Integração e entrega contínua (Gitlab CI/CD)
Gitlab é uma ferramenta completa para pipelines de software e automação de processos e respositório de código.

Para utilizar Gitlab neste desafio, tive que alterar a url que o Gitlab atendia, pois por padrão ele não é feito para ser acessado via caminhos relativos, portanto realizei o seguinte procedimento abaixo e automatizei o processo com Ansible.
[https://docs.gitlab.com/ee/install/relative_url.html](https://docs.gitlab.com/ee/install/relative_url.html)

## Registro para containers (Docker Hub)
Para construir e publicar a imagem da aplicação, foi utilizado `Docker Hub`, por dois motivos:

* Imagem da aplicação era genérica e não há nenhum dado sensível.
* Para utilizar o registro interno do Gitlab eu prefiro sempre certificados válidos, como a AWS é proibida de ter seu domínio utilizada com Lets Encrypt, preferi seguir a solução adequada neste caso, utilizar certificados válidos sem nenhum custo adicional (como um domínio, por exemplo).

## Como fazer o deploy da infraestrutura

Todo o deploy se encontra no script `runme.sh`.

### Como utilizar o script

Este script necessita dois parâmetros.
* Ação
* Nome do cliente

* Ação é o que desejamos fazer, como:
  * Construir toda infraestrutura.
  * Deletar toda infraestrutra, porém esta opção requer confirmação.
  * Rodar playbook para o cliente/projeto.
  * Mostrar informações de endpoints, como SSH e acesso ao Gitlab e aplicação.

* Nome do cliente
  * A estrutura de diretórios com Terraform foi justamente pensada para ser fácil o reuso para outros projetos.
  * Cada diretório contêm sua infraestrutura necessária para execução.

Para executar o script, digite no terminal `bash runme.sh` e verifique a saída. A saída é bem explicativa com uma ajuda de quais funcionalidades podemos realizar.

Sintaxe básica de Utilização: `bash runme.sh [OPÇÃO] [NOME DO CLIENTE]`

### Como conectar no servidor com SSH
Durante o processo de criação da infraestrutura na AWS com Terraform foram criadas as chaves de acesso ao servidor, elas estão em `/tmp/tls_key.pem` em sua máquina.