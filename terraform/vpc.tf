# Main VPC  #

resource "aws_vpc" "main-vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}



# Public Subnets 


resource "aws_subnet" "public-subnet1" {
  vpc_id = aws_vpc.main-vpc.id                          # Referencing the VPC ID        
  cidr_block = "10.0.1.0/24"                                           
  availability_zone = "eu-west-2a"
  
  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = aws_vpc.main-vpc.id                          # Referencing the VPC .id        
  cidr_block = "10.0.2.0/24"                                           
  availability_zone = "eu-west-2b"
  
  tags = {
    Name = "public-subnet2"
  }
}

# Private Subnets 

resource "aws_subnet" "private-subnet1" {
  vpc_id = aws_vpc.main-vpc.id                          # Referencing the VPC .id        
  cidr_block = "10.0.3.0/24"                                           
  availability_zone = "eu-west-2a"
  
  tags = {
    Name = "private-subnet1"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id = aws_vpc.main-vpc.id                          # Referencing the VPC .id        
  cidr_block = "10.0.4.0/24"                                          
  availability_zone = "eu-west-2b"
  
  tags = {
    Name = "private-subnet2"
  }
}



# Internet Gateway #

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "igw"
  }
}


# NAT Gateway, Elastic Load Balancer and Route Table #

resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  subnet_id     = aws_subnet.public-subnet1.id
  allocation_id = aws_eip.nat-eip.id
  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "private-rt-combined" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "private-rt-combined"                                      ###
  }
}

resource "aws_route_table_association" "private-rt1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt-combined.id
}

resource "aws_route_table_association" "private-rt2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt-combined.id
}

resource "aws_route_table" "public-rt-combined" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-combined"
  }
}

resource "aws_route_table_association" "public-rt1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt-combined.id
}

resource "aws_route_table_association" "public-rt2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt-combined.id
}


# Security Groups #

resource "aws_security_group" "threat-sg" {
  name        = "threat-sg"
  description = "allow HTTP, HTTPS, port3000 inbound and allow all outbound"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
  from_port   = "80"
  to_port     = "80"
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"                    # For security group (ingress/egress) = "protocol" 
  }
  
  ingress {
  from_port   = "443"
  to_port     = "443"
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp" 
  }

  ingress {
  from_port   = "3000"
  to_port     = "3000"
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  }

  egress  {
  from_port   = "0"
  to_port     = "0"
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "-1"
  }

 tags = {
    Name = "threat-sg"
  }
}
