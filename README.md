# desafio
O desafio consiste em construir uma stack de infraestrutura que provisione um ambiente para rodar uma aplicação backend rest hipotética, com duas réplicas respondendo em
um Load Balancer, e uma aplicação frontend estática, ambas respondendo pelo mesmo DNS, porém com contextos (paths)distintos.
Passos Do Projeto:
1-Criação de novo repositório no Github
3-Em Actions , vincular o workflow :
Terraform
By HashiCorp

Set up Terraform CLI in your GitHub Actions workflow.
                                                         ESTRUTURA DO YML
3-Vincular chaves access_key e secret_access_key na opções de variáveis de ambiente no github.
4-Edição do terraform.yml de acordo com suas configurações onde serão realizados os steps , jobs, da sua actions.
5- terraform.yml, Ajuste dos jobs com opções do terraform documentação da propria hashicorp
6- terraform.yml, edição dos jobs como imagem de s.o que vai rodar o step de instalção do terraform e toda sua execução (no meu caso Ubuntu)
7- terraform.yml, inicie os steps, verifique o processo de instalação do terraform com a versão desejada e adicione comando para direcionar o binário do mesmo para execução correta e devidas permissões.
8- terraform.yml, configuração ainda do step para init do terraform ( este deve analisar o processo de onde o backend irá executar, podendo assim ser necessário iniciar com terrraform init -reconfigure)
9-terraform.yml, continuando crie a etapa de validação de sua estrutura do HCL do terraform, com o comando terraform validate, onde verifica as questões de sintaxe de sua estrutura.
10-terraform.yml, step do comando terraform plan , após ok da validação.
11-terraform.yml, finalizando com terraform apply -auto-approve onde o mesmo não vai solicitar o aceite via "yes" para rodar o comando especificamente.
                                                         ESTRUTURA HCL TERRAFORM
1-Para este processo realizei o download do projeto via DESKTOP GITHUB e abri os arquvios via VSCODE para manipulação das minhas estruturas TF.
2-Com a estrutura vinculada fica tranquilo de realizar os testes localmente antes de realizar o commit para github.
3-Configuração da main com providers baseado na documentação da hashicorp, contendo souce = "hashicorp/aws" version="~3.0" , onde será meu backend no caso S3 da aws nome do bucket, regiao da minha infraestrutura cloud e por fim vinculo com minha chave que foi configurada via aws configure.
4-Construção do ambiente VPC , SUBNETS, ACL, ROUTE TABLE, INTERNET GATEWAY, EC2, com utilização de variaveis e modulos para funcionamento do projeto.

