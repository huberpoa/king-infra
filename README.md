# Divertindo-se com Infra as Code - Desafio Prático

## Tecnologias e por quê?

Para esse projeto, decidi utilizar o Google Cloud Platform e o GitLab para trabalhar com o repositório e o CI/CD.
Já nas ferramentas de automatização, utilizei o Terraform para provisionar as instâncias no GCP e Ansible para fazer as configurações dos ambientes.
Como eu já tinha participado do projeto anterior, eu já tinha 90% da estrutura pronta para utilizar nesse novo processo.
Porém, para ser justo, eu resolvi utilizar outras tecnologias que eu não tinha utilizado no processo anterior.
No primeiro processo, eu trabalhei com a AWS como provider e o Jenkins para o CI/CD e o Ansible para criar as instâncias e realizar toda a configuração da estrutura. 

Na minha experiência com a utiilização da AWS e GCP, as configurações a serem realizadas na AWS são bem complexas e você precisa compreender muito bem a estrutura e nomenclatura dos recursos para ter um trabalho mais objetivo.
Comparando com o GCP, a estrutura e nomenclatura do recursos são mais simples e mais fáceis de trabalhar.
Além disso, a conta free da AWS disponibiliza uma máquina que não é tão potente e que na hora de subir o GitLab, ele não consegue.
Esse foi um dos motivos na prova anterior, de utilizar o Jenkins por ele ser mais leve.

Já para o Terraform, escolhi trabalhar com ela por ser uma ferramenta muito simples para criar uma instância/máquina no ambiente Cloud.
Além disso, a sua instalação no ambiente local é muito fácil, pois você baixa o binário e insere no /usr/bin da sua máquina.

O Ansible, eu utilizei por ter uma documentação muito sólida e com uma boa comunidade.
E apesar de a sintaxe ser um pouco chata com relação a formatação pois não pode haver espaços soltos, ela utiliza uma linguagem chamada YAML que é de fácil entedimento para nós. 

## Decisões

Como já mencionado acima, tive a decição de trabalhar com o provider e ferramentas pela a questão de simplicidade e pelas experiências anteriores.
Quanto ao planejamento, não tive impasses para formar a estrutura pois consegui formalizar a estrutura antes de iniciar e a partir desse primeiro planejamento e consegui prosseguir até o final, a não ser as dificuldades abaixo:

As dificuldades que obtive foram no registry que criei e também no deploy do container no ambiente de produção a partir do pipeline que era executado no CI/CD.
O problema com o registry era que quando era feito o push ou pull para ele, era retornado a informação de que ele não tinha HTTPS.
E como não tinha uma forma de criar um Let's Encrypt para corrigir esse problemas, criei um SSL auto-assinado.
Mas infelizmente, com o certificado auto-assinado na hora de realizar o push ou pull, ele não conseguia validar o certificado.
Então, depois de ver alguns fóruns, consegui encontrar uma solução de inserir o certificado auto-assinado dentro do diretório certs.d no diretório do docker (/etc/docker). Somente dessa forma, eu consegui fazer os procedimentos de push e pull.

Quanto ao deploy, no .gitlab-cy.yml eu não tinha uma ideia formada para que fosse feito o deploy do container no servidor de produção.
Depois de pensar em algumas formas, tive a ideia de colocar a chave privada de um usuário criado no servidor de produção em uma variável no GitLab e apartir do SSH, enviar os comandos de docker pull e docker run.
Para fazer a utilização do SSH e chave, resolvi utilizar o ssh-agent e com um auxilio de fórum, consegui configurar certo o ssh-agent e dessa forma o deploy funcionou perfeitamente.

## Como utilizar?

Criei um arquivo Shell Script para que fosse realizado a criação da estrutura. 
O arquivo que criei é o run.sh. Para utilizar esse sh, execute o comando "chmod +x run.sh" e depois execute "./run".
Nesse arquivo, criei todo o passo a passo dos processos que são necessárias para criar a estrutura.

William Albiero
