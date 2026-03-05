provider "aws" {
  region ="ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.16.0/20"

  tags = {
    Name = "my-subnet-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-IG"
  }
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.main.id
    tags = {
    Name = "my-route_table"
  }
  
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.route.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id 
}

resource "aws_route_table_association" "associate" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_instance" "jume" {
    ami = "ami-051a31ab2f4d498f5"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_1.id
    vpc_security_group_ids = [aws_security_group.ec2_sg.subnet_id]
    key_name = "Avdhoot-key"
    tags = {
    Name = "Jume_server"
  }
  
}