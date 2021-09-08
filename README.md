# DESAFIO <h1>
O desafio consiste em construir uma stack de infraestrutura que provisione um ambiente para rodar uma aplicação backend rest hipotética, com duas réplicas respondendo em um Load Balancer, e uma aplicação frontend estática, ambas respondendo pelo mesmo DNS, porém com contextos (paths) distintos.

### Passo a passo do projeto<h1>

* Criação de novo repositório no Github

* Em Actions, vincular o workflow:

  * Terraform:  By HashiCorp


## Estrutura do YML<h1>
* Vincular chaves access_key e secret_access_key da aws na opções de variáveis de ambiente no github.

### Edição do terraform.yml de acordo com suas configurações, onde serão realizados os steps e jobs da sua actions.<h1>

* Ajuste dos jobs com opções do terraform documentação da propria hashicorp.

* Edição dos jobs como imagem de s.o que vai rodar o step de instalção do terraform e toda sua execução (no meu caso Ubuntu).

* Inicie os steps, verifique o processo de instalação do terraform com a versão desejada e adicione comando para direcionar o binário do mesmo para execução correta e devidas permissões.

* Configuração ainda do step para init do terraform ( este deve analisar o processo de onde o backend irá executar, podendo assim ser necessário iniciar com terrraform init -reconfigure).

* Continuando crie a etapa de validação de sua estrutura do HCL do terraform, com o comando terraform validate, onde verifica as questões de sintaxe de sua estrutura.

* Step do comando terraform plan, após ok da validação.

* Finalizando com terraform apply -auto-approve onde o mesmo não vai solicitar o aceite via "yes" para rodar o comando especificamente.

### Estrutura hcl terraform<h1>
 >Toda estrutura foi feita em Ohio, pois em Virginia está o projeto terraform, este baseado no mesmo.
  
* Para este processo realizei o download do projeto via DESKTOP GITHUB e abri os arquivos via VSCODE para manipulação dos arquivos .tf (terrafile).

* Com a estrutura vinculada fica tranquilo de realizar os testes localmente antes de realizar o commit para github.

* Configuração da main com providers baseado na documentação da hashicorp, contendo source = "hashicorp/aws" version="~3.0", onde será meu backend no caso S3 da aws nome do bucket, região da minha infraestrutura cloud e por fim, vínculo com minha chave que foi configurada via aws configure.

* Construção do ambiente VPC, SUBNETS, ACL, ROUTE TABLE, INTERNET GATEWAY, EC2, com utilização de variáveis e módulos para funcionamento do projeto.

* Instâncias EC2, realizado os determinados vínculos à minha estrutura de VPC.

* Construção do load balancer feito via deshboard (mesmo processo da estrutura do REPOSITÓRIO TERRAFORM).

>Projeto futuro adicionar estrutura do load neste abiente.

Estrutura similar abaixo:

Application Load Balancer
```
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}
```
E realizar os devidos vínculos ao Target Group, que neste caso seria seguindo o modelo abaixo:

```
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```


### Estrutura do kubernetes<h1>
  
Estrutura montada para kubernetes multimaster vínculo com haproxy (podemos utilizar um DNS de um load balancer criado na AWS, mas neste caso o load foi criado acima de toda estrutura)
##### Passo a passo:

Provisionar as 7 máquinas na aws, sendo 3 _MASTERS_, 3 _WORKERS_ para o k8s e uma máquina utilizaremos com aplicação do _HAPROXY_;
  
* Maquina HAPROXY:

Simples processo de Mapear estruturas master do K8S, para que elas possam se comunicar reconhecendo o hostname:
```
vim /etc/haproxy/haproxy_config
```
Acrescentar o script abaixo:

### Frontend kubernetes
```
  mode tcp
  bind 10.0.1.20:6443
  option tcplog
  default_backend k8s-masters
```

### Backend k8s-masters
```
  mode tcp
  balance roundrobin    
  option tcp-check
  server k8s-master-01 10.0.1.95:6443 check fall 3 rise 2    
  server k8s-master-02 10.0.1.82:6443 check fall 3 rise 2
  server k8s-master-03 10.0.1.185:6443 check fall 3 rise 2
``` 
 
  
*  Restart do haproxy:
```
 systemctl restart haproxy
```
### Configuração cluster multimaster k8s


* Logar nas maquinas e atualizar a lista das versões dos pacotes disponíveis:
```
 apt-get update 
```
* Setar os devidos hostnames em cada uma, tanto para as 3 workers quanto para as 3 masters (claro alterando a numeração de 1 - 3 )

``` 
hostname k8s-master-01
echo "k8s-master-01" > /etc/hostname
```
```
hostname k8s-worker-02
echo "k8s-worker-02" > /etc/hostname
```
Acrecentar ip e nome do haproxy em todas máquinas:
```
vim /etc/hosts
10.0.1.75 k8s-haproxy
```
>Execute os passos abaixo somente nas máquinas _Masters_, depois, iremos iniciar os procedimentos nas instâncias _Workers_.

 Após este processo iniciamos com a instalação do Docker:
```
curl -fsSL https://get.docker.com | bash
```
Para garantir que o driver Cgroup do Docker será configurado para o systemd, que é o gerenciador de serviços padrão utilizado pelo Kubernetes execute os comandos abaixo:

* Para a família Debian, execute o seguinte comando:
  
```
cat > /etc/docker/daemon.json
 <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```
```  
sudo mkdir -p /etc/systemd/system/docker.service.d
```
Agora basta reiniciar o Docker:
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
Para finalizar, verifique se o driver Cgroup foi corretamente definido.
```
docker info | grep -i cgroup
```
Se a saída foi `Cgroup Driver: 
systemd`, está tudo ok!

### INSTALANDO K8S<h1>

Execute os comandos abaixo:
```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
```

> O comando abaixo é para ser executado somente em uma máquina master, no meu caso _k8s-master-01_.

> Importante, após o comando abaixo, salvar os tokens de acesso dos masters e dos workers, para facilitar o andamento.
```  
kubeadm init --control-plane-endpoint "k8s-haproxy:6443" --upload-certs
```
Colete o comando de inserção dos _Masters_, deve ser similar ao exemplo abaixo:
```
  kubeadm join k8s-haproxy:6443 --token p35ebh.y5wcr2zhjuwdy28d \
        --discovery-token-ca-cert-hash sha256:313a5119c15bc35588fe2b3ad4802b51801 \
        --control-plane --certificate-key 0e14303e78813bb4c4460e419438eed2493a34b38c90a9
```
E execute o comando do exemplo acima nas outras duas máquinas _Masters_.

Dando continuidade ainda no _k8s-master-01_, execute:


```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

## Configuração WORKERS <h1>

Setar hostname das maquinas de 01 a 03:

```
hostname k8s-worker-01

echo "k8s-worker-01" > /etc/hostname
```
Acrecentar ip e nome do haproxy em todas máquinas (substitua os valores de ip de acordo com suas instâncias):
```
vim /etc/hosts
10.0.1.75 k8s-haproxy
```
Instalando docker: 
```
curl -fsSL https://get.docker.com | bash
```
Para garantir que o driver Cgroup do Docker será configurado para o systemd, gerenciador de serviços padrão utilizado pelo Kubernetes, execute os comandos abaixo:

  * Para a família Debian, execute o seguinte comando:


```
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
```

```
sudo mkdir -p /etc/systemd/system/docker.service.d
```
Agora basta reiniciar o Docker.

```
sudo systemctl daemon-reload

sudo systemctl restart docker
```
Para finalizar, verifique se o driver Cgroup foi corretamente definido.
```
docker info | grep -i cgroup
```

Se a saída foi `Cgroup Driver: systemd`, está tudo ok!

## Instalando k8s maquinas workers <h1>

Executar os comandos:

```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
```
Insira o token gerado na maquina k8s-master-01 para juntar ao cluster, execute em todas as _Workers_ o comando similar ao abaixo:
```
kubeadm join k8s-haproxy:6443 --token p35h.y5wcy28d \
        --discovery-token-ca-cert-hash sha256:31371fba5119c15bc35588fe26e184802b51801
``` 
Retorne a máquina  _k8s-master-01_.

Verifique se todos os nodes realizaram conexão executando:
```
kubectl get nodes
```
Com isso criado, deve realizar os ajustes a nível das aplicações, construção dos aquivos yaml, expondo os services NodePort, estrutura simples de NGINX , APACHE2 para nível de exemplo executando, vou acrescentando no decorrer do tempo, grafana, zabbix, entre outros, de acordo com as demandas e tempo para montagem das estruturas. 

> Lembrando que, por ser ambiente de teste, não foi utilizado Ingress, Helm, sendo isso uma demanda para projetos futuros.

Obrigado pela atenção!
                                                                        
                                                                                
