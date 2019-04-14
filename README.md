# Desafio Kinghost
## Execução
### Pré-configuração
#### Terraform
Editar o arquivo *terraform/gcp/vars.tf* informando seus dados para a criançao
 do ambiente.

Depois o script build_environment.sh pode ser executado para o setup do ambiente.


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


### Ansible
Foi utilizado uma role de um terceiro para a instalação do Docker no Ansible:
 https://github.com/geerlingguy/ansible-role-docker

### Docker
Usar versao no nome da imagem: https://docs.docker.com/compose/environment-variables/


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
