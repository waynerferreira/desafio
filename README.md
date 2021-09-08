# DESAFIO <h1>
O desafio consiste em construir uma stack de infraestrutura que provisione um ambiente para rodar uma aplicação backend rest hipotética, com duas réplicas respondendo em
um Load Balancer, e uma aplicação frontend estática, ambas respondendo pelo mesmo DNS, porém com contextos (paths)distintos.

###                                                        PASSO A PASSO DO PROJETO<h3>

* 1-Criação de novo repositório no Github

* 2-Em Actions , vincular o workflow :

Terraform
By HashiCorp

Set up Terraform CLI in your GitHub Actions workflow.


##                                                         ESTRUTURA DO YML<h3>
* 3-Vincular chaves access_key e secret_access_key na opções de variáveis de ambiente no github.

* 4-Edição do terraform.yml de acordo com suas configurações onde serão realizados os steps , jobs, da sua actions.

* 5- terraform.yml, Ajuste dos jobs com opções do terraform documentação da propria hashicorp.

* 6- terraform.yml, edição dos jobs como imagem de s.o que vai rodar o step de instalção do terraform e toda sua execução (no meu caso Ubuntu).

* 7- terraform.yml, inicie os steps, verifique o processo de instalação do terraform com a versão desejada e adicione comando para direcionar o binário do mesmo para execução correta e devidas permissões.

* 8- terraform.yml, configuração ainda do step para init do terraform ( este deve analisar o processo de onde o backend irá executar, podendo assim ser necessário iniciar com terrraform init -reconfigure).

9-terraform.yml, continuando crie a etapa de validação de sua estrutura do HCL do terraform, com o comando terraform validate, onde verifica as questões de sintaxe de sua estrutura.

* 10-terraform.yml, step do comando terraform plan , após ok da validação.

* 11-terraform.yml, finalizando com terraform apply -auto-approve onde o mesmo não vai solicitar o aceite via "yes" para rodar o comando especificamente.

###                                                         ESTRUTURA HCL TERRAFORM<h3>
#####                                                         TODA ESTRUTURA FEITO EM OHIO POIS EM VIRGINIA ESTA O PROJETO TERRAFORM, ESTE BASEADO NO MESMO<h5>
* 1-Para este processo realizei o download do projeto via DESKTOP GITHUB e abri os arquvios via VSCODE para manipulação das minhas estruturas TF.

* 2-Com a estrutura vinculada fica tranquilo de realizar os testes localmente antes de realizar o commit para github.

* 3-Configuração da main com providers baseado na documentação da hashicorp, contendo souce = "hashicorp/aws" version="~3.0" , onde será meu backend no caso S3 da aws nome do bucket, regiao da minha infraestrutura cloud e por fim vinculo com minha chave que foi configurada via aws configure.

* 4-Construção do ambiente VPC , SUBNETS, ACL, ROUTE TABLE, INTERNET GATEWAY, EC2, com utilização de variaveis e modulos para funcionamento do projeto.

* 5-Construção das Instancias , realizado os determinados vinculos a minha estrutura de VPC.

* 6-Construção do load balancer feito via deshboard ( mesmo processo da estrutura do REPOSITÓRIO TERRAFORM. ( Projeto futuro add estrutura do load neste abiente)

###                                                       ESTRUTURA KUBERNETES<h3>
Estrutura montada para kubernetes MULTIMASTER vínculo com HAPROXY (PODEMOS UTILIZAR UM DNS DA AWS COMO LOAD TAMBÉM, MAS NESTE CASO O LOAD FOI CRIADO ACIMA DE TODA ESTRUTURA)
Passo a passo:
Maquina HAPROXY:
Simples processo de Mapear estruturas master do K8S
vim /etc/haproxy/haproxy_config
acrescentar o script abaixo:

ˋˋˋ
frontend kubernetes
  mode tcp
  bind 10.0.1.20:6443
  option tcplog
  default_backend k8s-masters

backend k8s-masters
  mode tcp
  balance roundrobin    
  option tcp-check
  server k8s-master-01 10.0.1.95:6443 check fall 3 rise 2    
  server k8s-master-02 10.0.1.82:6443 check fall 3 rise 2
  server k8s-master-03 10.0.1.185:6443 check fall 3 rise 2
 ˋˋˋ  
  
  Restar do haproxy: systemctl restart haproxy

Configuração cluster multimaster k8s
Após provisionar as 7 máquinas na aws em ohio
logar nas maquinas apt-get update em todas 
setar os devidos hostnames em cada uma tanto para as 3 workers quanto para as 3 masters (claro alterando a numeração de 1 - 3 )
 
hostname k8s-master-01
echo "k8s-master-01" > /etc/hostname

hostname k8s-worker-02
echo "k8s-worker-02" > /etc/hostname

Após este processo iniciamos com a instalação do Docker

curl -fsSL https://get.docker.com | bash

Para garantir que o driver Cgroup do Docker será configurado para o systemd, que é o gerenciador de serviços padrão utilizado pelo Kubernetes execute os comandos abaixo:

Para a família Debian, execute o seguinte comando:
  
ˋˋˋ
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
 ˋˋˋ
  
sudo mkdir -p /etc/systemd/system/docker.service.d

Agora basta reiniciar o Docker.

sudo systemctl daemon-reload
sudo systemctl restart docker

Para finalizar, verifique se o driver Cgroup foi corretamente definido.

docker info | grep -i cgroup

Se a saída foi Cgroup Driver: systemd, esta tudo ok! bora bora!

INSTALANDO K8S

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

Todos comando acima devem ser executados em todas as maquinas, o comando abaixo é para ser executado somente em uma maquina master no meu caso k8s-master-01

######IMPORTANTE APÓS O COMANDO ABAIXO SALVAR OS TOKENS DE ACESSO DOS MASTERS E DOS WORKERS<h6>
  
kubeadm init --control-plane-endpoint "elbterraformk8slz-654277202.us-east-1.elb.amazonaws.com:6443" --upload-certs

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

######Configuração WORKERS<h6>

hostname das maquinas de 01 a 03
ˋˋˋ
hostname k8s-worker-01
echo "k8s-worker-01" > /etc/hostname
ˋˋˋ
  
acrecenta ip e nome do haproxy 
vim /etc/hosts

10.0.1.75 k8s-haproxy 

curl -fsSL https://get.docker.com | bash

Para garantir que o driver Cgroup do Docker será configurado para o systemd, que é o gerenciador de serviços padrão utilizado pelo Kubernetes execute os comandos abaixo:

Para a família Debian, execute o seguinte comando:

 ˋˋˋ
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
ˋˋˋ
  
sudo mkdir -p /etc/systemd/system/docker.service.d

Agora basta reiniciar o Docker.

sudo systemctl daemon-reload
sudo systemctl restart docker

Para finalizar, verifique se o driver Cgroup foi corretamente definido.

docker info | grep -i cgroup

Se a saída foi Cgroup Driver: systemd, esta tudo ok! bora bora!

######INSTALANDO K8S<h6>

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

insira o token gerado na maquina k8s-master-01 para juntar ao kluster
ˋˋˋ
kubeadm join k8s-haproxy:6443 --token p35ebh.y5wcr2zhjuwdy28d \
        --discovery-token-ca-cert-hash sha256:3137191f94ccaa01f.....
 ˋˋˋ 
  
kubectl get nodes
  verificar se todos os nodes realizaram conexão.
  Com isso criado os devidos yaml para aplicações rodar, expondo os services NodePort, estrutura simples de NGINX , APACHE2 para nível de exemplo executando, vou acrescentando no derrorrer do temo, grafana , zabbix entre outros o mesmo via de acordo com as demandas e tempo para montagem das estruruas. 
  
  
  lembrando que por ser ambiente de teste não foi utilizado INGRESS HELM para enriquecer todo o projeto, sendo isso uma demanda para projetos futuros.
  
  Obrigado pela Atenção! Desculpe os erros de português irei ajustando com o tempo!!!!!
                                                                        
                                                                                
