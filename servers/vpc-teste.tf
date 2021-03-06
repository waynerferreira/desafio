resource "aws_vpc" "vpcteste" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpcteste"
  }
}
resource "aws_subnet" "subnet-testeA" {
  vpc_id     = "${var.vpcteste}"
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "use2-az1"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-testeA"
  }
  depends_on = [aws_vpc.vpcteste]
}
resource "aws_subnet" "subnet-testeB" {
  vpc_id     = "${var.vpcteste}"
  cidr_block = "10.0.2.0/24"
  availability_zone_id = "use2-az2"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "subnet-testeB"
  }
  depends_on = [aws_vpc.vpcteste]
}

resource "aws_network_acl" "acl_teste" {
  vpc_id = "${var.vpcteste}"
  subnet_ids = [aws_subnet.subnet-testeA.id]
    tags = {
    name = "acl_teste"
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }


egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
    ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
    ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
     
}

resource "aws_internet_gateway" "igw-teste" {
    vpc_id = "${var.vpcteste}"

    tags = {
      Name = "igw-teste"
    }
}    
resource "aws_route_table" "rt-teste" {
  vpc_id = "${var.vpcteste}"
  tags = {
    Name = "rt-teste"
  }
}

resource "aws_route" "rotas-teste" {
  route_table_id = "${aws_route_table.rt-teste.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw-teste.id}"

  depends_on = [aws_route_table.rt-teste]
}
resource "aws_route_table_association" "rt-subnet-testeA" {
  subnet_id = "${var.subnet-testeA}"
  route_table_id = "rtb-0c8140034a77a8a5a"

 }
resource "aws_route_table_association" "rt-subnet-testeB" {
  subnet_id = "${var.subnet-testeB}"
  route_table_id = "rtb-0c8140034a77a8a5a"

 }
