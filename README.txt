Resposta para o desafio
===============================
Pensei para poder atender esse projeto o seguinte desenvolvimento:
    • Google cloud como escolha de cloud, não tinha trabalhado com nenhuma das duas cloud propostas no desafio, como já tinha um breve conhecimento do google cloud escolhi a mesma.
    • Terraform e Ansible para provisionar e configurar as VM no google cloud
    • Gitlab e gitlab-runner para poder realizar o ci/cd no Docker 

OBS: Não consegui completar, parei na parte de colocar em produção o site, parei na parte do pipeline para colocar o site em produção.


Como reproduzir:
------------


Dependencias para poder executar o projeto:
Instalar o terraform, ansible, python-pip, apache-libcloud, requests google-auth

1) Criar um novo projeto no GCP, criar uma conta de serviço, criar uma credencial JSON para poder utilizar no terraform e no ansible realizar o download da mesma e colocar dentro dos diretórios “terraform” e “ansible”, alterar o nome da credencial para “google-account.json”.
Executar:
gcloud init
gcloud auth login

2) Dentro do diretório terraform utilizar o comando terraform aplly preencher as perguntas, ele irá provisionar duas VM uma para o Gitlab e a outra para o gitlab-runner e o Docker.

3) Entrar dentro do diretório do ansible:

    • Acessar o arquivo gce.ini e preencher as informações, elas podem ser encontradas no arquivo de credenciais json baixado.
      gce_service_account_email_address 
	gce_service_account_pem_file_path = 
	gce_project_id = 
	gce_zone = 

    • Acessar o arquivo setup.yml
      Dentro do arquivo na linha “Instala o Gitlab” alterar o “IP-INTERNO-DA-VM” pelo IP interno da VM do Gitlab, salvar o arquivo
      
    • Acessar o arquivo Docker-server.yml
      Dentro do arquivo alterar a linha “url "http://IP-INTERNO-DA-VM-GITLAB/” pelo ip da VM do Gitlab
      
    • Executar:
      ansible-playbook -i gce.py setup.yml -e 'ansible_python_interpreter=/usr/bin/python3'
      ansible-playbook -i gce.py Docker-server.yml -e 'ansible_python_interpreter=/usr/bin/python3'
      
    • Se tudo der certo nesse ponto temos o gitlab instalado, gitlab-runner e docker também.
      
    • Acessar o gitlab pelo endereço externo da VM gitlab, criar senha para o usuário root.
      
    • Criar um projeto no gitlab.
      
4) Acessar o diretório gitlab-repo,realizar o push para o projeto dentro do gitlab que foi criado anteriormente, o arquivo .gitlab-ci.yml deve começar a realizar o pipeline.

Bom nesse ponto eu parei, encontrei vários problemas para conseguir realizar o pipeline que eu tinha projetado, pensei em construir imagens docker e poder disponibiliza-las em “produção”, fiz alguns testes mas não foram bem sucedidos. Obrigado, espero que tenha ficado claro as informações.  



