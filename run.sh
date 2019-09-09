#!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                                                               echo Insira a AWS_ACCESS_KEY:                                                                                                                                                                                                                read access_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Insira a AWS_SECRET_KEY:                                                                                                                                                                                                                read secret_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Executando Playbook:                                                                                                                                                                                                                                                                                                                                                                                                                                                                 /usr/local/bin/ansible-playbook -i hosts --extra-vars "AWS_ACCESS_KEY=$access_key   AWS_SECRET_KEY=$secret_key" gitlab.yml                                                                                                                                                                                                                                                  #!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                                                               echo Insira a AWS_ACCESS_KEY:                                                                                                                                                                                                                read access_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Insira a AWS_SECRET_KEY:                                                                                                                                                                                                                read secret_key                                                                                                                                                                                                                                                                                                                                                                                                                                                                           echo Executando Playbook:                                                                                                                                                                                                                                                                                                                                                                                                                                                                 /usr/local/bin/ansible-playbook -i hosts --extra-vars "AWS_ACCESS_KEY=$access_key   AWS_SECRET_KEY=$secret_key" gitlab.yml                                                                                                                                                                                                                                                  #!/bin/bash
##################################################################### Functions #######################################################################

## Function para pegar se os recursos estão instalados e mostra as suas versões 
check_tools(){
## Setado a cor dos retornos para verde    
tput setaf 2
##Executa o comando do terraform e não retorna ao console
terraform --version > /dev/null 2>&1

## Verifica se a execução do comando acima foi realizado com sucesso, caso sim mostra a versão do recurso
## Caso contrário, ele informa que deve ser instalado e encerra a execução do script
if [ $? -eq 0 ]
then
    echo "O Terraform está instalado na sua máquina"
    terraform --version
    echo ""
else
    echo "Terraform não está instalado!"
    echo "Você precisa realizar a instalação desse recurso para prosseguirmos com a construção da nossa estrutura!"
    exit 3
fi

ansible --version > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "O ansible está instalado na sua máquina"
    ansible --version
    echo ""
else
    echo "Ansible não está instalado!"
    echo "Você precisa realizar a instalação desse recurso para prosseguirmos com a construção da nossa estrutura!"
    exit 3
fi

tput sgr0
}

## Função que cria as instâncias no GCP com o terraform e executa as roles de configuração com o ansible 
start_structure(){ 

echo "Perfeito! Então vamos iniciar a construção da nossa estrutura. Mas, primeiramente precisamos que você acesse o painel do GCP e crie um novo projeto."
echo "Depois de criado o novo projeto no GCP, crie uma credencial para você. Para criar a credencial vá no menu APIs e Serviços > Credenciais > Criar credencias > Criar chave da conta de serviço."
echo "Preencha as informações e depois de clicar em criar, você irá fazer o download de um arquivo JSON com as suas credencias. GUARDE ESSE ARQUIVO E NÃO DISPONIBILIZE ELE PARA NINGUÉM"
echo "Depois de criado a credencial, verifique se o seu usuário possui uma chave SSH pois vamos precisar cadastrar ela nos servidores que vamos criar."
echo "Caso não tenha, utilize o comando ssh-keygen e aperte <ENTER> para prosseguir os passos e depois será criado um diretório chamado .ssh dentro da sua home com os arquivos."

echo ""
echo ""

# Pega a informação de onde está o JSON das credencias do GCP 
tput setaf 3; echo "Me informe o caminho onde está o arquivo JSON do GCP que você fez o download. Exemplo: /home/meuuser/Documentos/Minha-credencial-929482714.json"
read pathjson;
# Pega a informação de onde está a chave pública para que o usuário tenha acessa as instancias sem a senha 
echo "Me informe o caminho de onde está a sua chave pública. Exemplo: /home/meuuser/.ssh/id_rsa.pub" 
read pathpubkey;
# Pega a informação de qual o projeto criado no GCP
echo "Qual é o nome do projeto criado no GCP para criar a nossa estrutura:"
read nameproject;

## Vamos executar o terraform init para baixar os providers e depois executar o apply para criar as instâncias no GCP a partir dos dados que foram passados
cd ./terraform ; > hosts ; terraform init ; terraform apply -var="mypath=$pathjson" -var="user=$USER" -var="pub-key=$pathpubkey" -var="name-project=$nameproject";

## Verifica se a execução do comando acima foi executado com sucesso
echo ""
if [ $? -eq 0 ]
then
    tput setaf 2; echo "Nossas instâncias foram criadas com sucesso!"

else
    tput setaf 2; echo "Não foi possível criar as nossas instâncias!"
    exit 3
fi

tput sgr0; echo -e "Agora que você criou as instâncias, pegue os IP's e faça os seguintes apontamentos: \n
gitlab.seudominio.com para o IP do servidor gitlab-server conforme a ordem que mostra no output \
registry.seudomoinio.com para o mesmo IP do servidor gitlab-server \
seudominio.com para o IP do servidor web-server"

read -p "Pressione <ENTER> após a configuração do DNS para o seu domínio para que possamos prosseguir com a configuração da nossa estrutura!"

tput setaf 3; echo "Então agora, me informe o nome do seu domínio sem HTTP/HTTPS, www e barras"
read domain

echo "Perfeito! Agora que os servidores já estão criados e domínio já está apontando para os nossos servidores, vamos começar a configurar os nossos ambientes"
echo ""

echo "Primeiro, vamos instalar o docker nas instâncias."

cd ../ansible ; ansible-playbook -i ../terraform/hosts --extra-vars "USER=$USER" main-configure.yml


echo -e "\nAgora vamos configurar o nosso ambiente de produção!"

echo -e "Antes de prosseguirmos, verifique se o domínio e os subdomínios estão respondendo pelo os IP's configurados.\n"
read -p "Pressione <ENTER> quando você identificar que o domínio já está respondendo pelos IP's, pois é necessário que esteja ok para conseguirmos gerar o certificado Let's Encrypt!"

ansible-playbook -i ../terraform/hosts --extra-vars "USER=$USER DOMAIN=$domain" production-main.yml

echo -e "\nFeito a instalação do ambiente de produção, vamos realizar a instalação do GitLab e do nosso Registry do Docker.\n"
echo -e "A instalação do GitLab demora aproximadamente 4 minutos, então fique tranquilo!"

ansible-playbook -i ../terraform/hosts --extra-vars "USER=$USER DOMAIN=$domain" gitlab-main.yml

echo -e "Feito a instalação do GitLab, acesse o endereço gitlab.seudominio e coloque uma nova senha para o usuário root.\n"
echo -e "Acesse o GitLab com o usuário root e a senha que você cadastrou. \n Então, crie um novo projeto importando o repositório que eu disponibilizei no GitHub chamado devops.\n"
echo -e "Para importar o repositório do GitHub para o GitLab, clique na aba Import project e selecione o GitHub. \
Utilize esse token (2584ac7e7ac0868163aafeba5a55cf411e05bc95) para fazer a importação do repo devops.\n"

echo -e "Feito a importação, acesse o projeto e no menu Settings > CI / CD > Runners, pegue o token para registrar um novo runner.\n"
echo -e "Também, na mesma página vá em Variables e crie duas variáveis:"
echo "Uma chamada DEPLOY_KEY e a outra chamada DOMAIN. Você deve criar em maiúsculo."
echo "O valor da chave DEPLOY_KEY será a chave privada do usuário deploy criado no web-server."
echo "Então, acesse o servidor web-server, digite sudo su -l deploy e pegue o conteúdo do arquivo /home/deploy/.ssh/id_rsa e salve na chave DEPLOY_KEY."
echo -e "Já para a variável DOMAIN, coloque o domínio sem HTTP/HTTPS, www e barras.\n"

echo -e "Realizado essas configurações, vamos criar a runner para que possamos executar o CI / CD.\n"

echo "Informe o token para cadastrar um novo runner no GitLab:"
read tokenrunner

echo -e "/nVamos executar nossa task para criar o runner.\n"

ansible-playbook -i ../terraform/hosts --extra-vars "USER=$USER DOMAIN=$domain TOKEN_RUNNER=$tokenrunner" gitlab-runner-main.yml 

echo -e "Feito a configuração GitLab Runner, estamos com a nossa estrutura pronta.\n"
echo -e "Agora, é só partir para o abraço!!!"

}

## Função que irá remover tudo o que foi criado no GCP
destroy_structure(){

echo "Você tem certeza que deseja remover toda a estrutura criada? [y/N]"
read opdestroy

if [ $opdestroy = y || $opdestroy = Y ]
then 
    cd ./terraform ; > hosts ; terraform destroy -var="mypath=$pathjson" -var="user=$USER" -var="pub-key=$pathpubkey" -var="name-project=$nameproject";
else
    if [ $opdestroy = n || $opdestroy = N ]
    then
        exit 3
    fi
fi
}
############################################################################################################################################

################################################################# Main #####################################################################

## Iniciando a nossa interação com o usuário
echo "Olá! Seja muito bem-vindo!"
echo "Esse projeto foi desenvolvido utilizando as ferramentas Terraform e Ansible, fazendo a criação das máquinas no GCP (Google Cloud Platform). As versões utilizadas são: Terraform v0.12.8 e Ansible 2.8.4"
## Chama function para checar se as ferramentas estão instaladas
check_tools

## Verificar com o usuário o que ele deseja fazer se é criar a estrutura ou excluir ela
echo "Visto que as ferramentas estão devidamente instaladas na sua máquina, podemos prosseguir com a execução do nosso script."
echo "Para iniciarmos a execução do script, precisamos ver se você deseja criar a estrutura ou excluir ela."
echo "Então para iniciarmos a criação da nossa estrutura precisamos que você escolha entre a opção de iniciar a criação ou a opção de excluir toda a estrutura."
tput setaf 3; echo "(C)riar estrutura / (E)xcluir estrutura"
read option
tput sgr0

## Verifica qual opção o usuário escolheu e chama a sua respectiva função
if [ $option = C ]
then
        ## Função que cria toda a estrutura
        start_structure    
else
    if [ $option = E ]
    then
        ## Função que exclui tudo que foi criado
        destroy_structure
    
    else
        echo "Opção incorreta!"
        exit 3
    fi
fi