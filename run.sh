#!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                                                               echo Insira a AWS_ACCESS_KEY:                                                                                                                                                                                                                read access_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Insira a AWS_SECRET_KEY:                                                                                                                                                                                                                read secret_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Executando Playbook:                                                                                                                                                                                                                                                                                                                                                                                                                                                                 /usr/local/bin/ansible-playbook -i hosts --extra-vars "AWS_ACCESS_KEY=$access_key   AWS_SECRET_KEY=$secret_key" gitlab.yml                                                                                                                                                                                                                                                  #!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                                                               echo Insira a AWS_ACCESS_KEY:                                                                                                                                                                                                                read access_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Insira a AWS_SECRET_KEY:                                                                                                                                                                                                                read secret_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Executando Playbook:                                                                                                                                                                                                                                                                                                                                                                                                                                                                 /usr/local/bin/ansible-playbook -i hosts --extra-vars "AWS_ACCESS_KEY=$access_key   AWS_SECRET_KEY=$secret_key" gitlab.yml                                                                                                                                                                                                                                                  #!/bin/bash

# Pega a informação de onde está o JSON das credencias do GCP 
echo Me informe o caminho de onde está o arquivo JSON do GCP:
read pathjson;
# Pega a informação de onde está a chave pública para que o usuário tenha acessa as instancias sem a senha 
echo Me informe o caminho de onde está a sua chave pública: 
read pathpubkey;
# Pega a informação de qual o projeto criado no GCP
echo Qual é o projeto criado no GCP para criar a nossa estrutura:
read nameproject;

