provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "KLSS" {
  
  	cidr_block       = "10.0.0.0/16"
	instance_tenancy = "default"
	enable_dns_hostnames = true
	
	tags = {
   		 Name = "MY-VPC"
 	 }
  
  }
#Public subnet
resource "aws_subnet" "Public-sub" {
  vpc_id     = aws_vpc.KLSS.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PUBLIC "
  }
}

#Internet gatway
resource "aws_internet_gateway" "My-ig" {
  vpc_id = aws_vpc.KLSS.id

  tags = {
    Name = "IG"
  }
}

#Public route table
resource "aws_route_table" "My-rt" {
  vpc_id = aws_vpc.KLSS.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My-ig.id
  }

  tags = {
    Name = "FIR-RT"
  }
}
#route table association to subnet
resource "aws_route_table_association" "FIR-a" {
  subnet_id      = aws_subnet.Public-sub.id
  route_table_id = aws_route_table.My-rt.id
}

#Security group for VPC
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.KLSS.id

  tags = {
    Name = "SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.KLSS.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "IN-EC2" {
  ami                     = "ami-04b70fa74e45c3917"
  instance_type           = "t2.micro"
  subnet_id		  = aws_subnet.Public-sub.id
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  key_name 		  = "to_use"
  associate_public_ip_address = true
  #host_resource_group_arn = "arn:aws:resource-groups:us-west-2:012345678901:group/win-testhost"
  #tenancy                 = "host"
}
