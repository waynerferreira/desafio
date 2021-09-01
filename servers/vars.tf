variable "amis" {
    #type = map
    default = {
        "us-east-1" = "ami-08b2293fdd2deba2a"
        "us-east-2" = "ami-089fe97bc00bff7cc"
    }
}

variable "cdirs_acesso_remoto" {
    default = ["0.0.0.0/0"]
}
variable "vpcteste" {
    default = "vpc-0461eb792b9dd6671"
}
variable "subnet-testeA"{
    default = "subnet-050d0529d97294ba8"
}
variable "subnet-testeB"{
    default = "subnet-05a52da2d68ce083b"
}
variable "acl_teste"{
    default = "acl-0141d45a3a090cee5"
}
variable "igw-teste"{
    default = "igw-0c221ec2b68762076"
}
variable "sg_teste" {
    default = "sg-0e233af418e463671"
}
/*variable "sg_teste" {
    #type = map
#   description = "sg-0714a8294df4cb3ad"
    default = {
    aws_security_group = "sg-0c3d1c6d80cbc56d5"
    }
}
*/
variable "key_name" {
    default = "awswaynerohio"
}

variable "servers" {

}
/*
variable "blocks" {
    type = list (object({
        device_name = string
        volume_size = string
        volume_type = string
    }))
    description = "List of EBS block"
}
*/
/*
variable "name_instances" {
  #  type = string
    default = "k8s"
    description = "Nome das instancias EC2"
}
/*
variable "instance_type"{
    type = list (string)
    default = ["t2.micro","t3.medium"] 
    description = "The list of instance type"
}
*/