### VPC ###
resource "aws_vpc" "demo_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    tags = {
        Name = "Demo_VPC"
    }
}

### IGW ###
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.demo_vpc.id
    tags = {
        Name = "Internet Gateway"
    }
}

### NAT Gateway ###
resource "aws_eip" "nat_gateway_ip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id = aws_subnet.pub_1.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
      Name = "NAT Gateway"
  }
}

### VPC Subnets ###
resource "aws_subnet" "pub_1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pub_1_subnet_cidr_block
  availability_zone = var.pub_1_subnet_az

  tags = {
      Name = "Pub_1"
      "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "pub_2" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pub_2_subnet_cidr_block
  availability_zone = var.pub_2_subnet_az

  tags = {
      Name = "Pub_2"
      "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "pri_1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pri_1_subnet_cidr_block
  availability_zone = var.pri_1_subnet_az

  tags = {
      Name = "Pri_1"
      "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "pri_2" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.pri_2_subnet_cidr_block
  availability_zone = var.pri_2_subnet_az

  tags = {
      Name = "Pri_2"
      "kubernetes.io/role/internal-elb" = "1"
  }
}

### Route Tables ###
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.demo_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Public Route Table"
    }
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.demo_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = {
        Name = "Private Route Table"
    }
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "pub_1" {
    subnet_id = aws_subnet.pub_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_2" {
    subnet_id = aws_subnet.pub_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pri_1" {
    subnet_id = aws_subnet.pri_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "pri_2" {
    subnet_id = aws_subnet.pri_2.id
    route_table_id = aws_route_table.private_route_table.id
}

### NACL for Public Subnets ###
resource "aws_network_acl" "nacl_public" {
    vpc_id = aws_vpc.demo_vpc.id
    subnet_ids = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

    egress {
            protocol = "-1"
            rule_no = 200
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 0
            to_port = 0
        }

    ingress {
            protocol = "tcp"
            rule_no = 100
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 1024
            to_port = 65535
        }

    ingress {
            protocol = "tcp"
            rule_no = 300
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 80
            to_port = 80
        }

    ingress {
            protocol = "tcp"
            rule_no = 500
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 443
            to_port = 443
        }

    tags = {
        Name = "Public NACL"
    }
}

### NACL for Private Subnets ###
resource "aws_network_acl" "nacl_private" {
    vpc_id = aws_vpc.demo_vpc.id
    subnet_ids = [aws_subnet.pri_1.id, aws_subnet.pri_2.id]

    egress{
            protocol = "-1"
            rule_no = 200
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 0
            to_port = 0
        }

    ingress {
            protocol = "tcp"
            rule_no = 100
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 1024
            to_port = 65535
        }

    ingress {
            protocol = "tcp"
            rule_no = 300
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 80
            to_port = 80
        }

    ingress {
            protocol = "tcp"
            rule_no = 500
            action = "allow"
            cidr_block = "0.0.0.0/0"
            from_port = 443
            to_port = 443
        }

    tags = {
        Name = "Private NACL"
    }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.demo_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["Pub*"]
  }
}