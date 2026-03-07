provider "aws" {
  region     = "us-west-2"
  access_key = "access_key_example"
  secret_key = "secret_key_example"
}

resource "aws_vpc" "three_tier_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "nginx_subnet" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "nginx-subnet"
  }
}

resource "aws_subnet" "tomcat_subnet" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "tomcat-subnet"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "database-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "nginx_rt" {
  subnet_id      = aws_subnet.nginx_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
    Name = "nginx-sg"
  }
}

resource "aws_security_group" "tomcat_sg" {
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "tomcat-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.tomcat_sg.id]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_instance" "nginx_server" {
  ami           = "ami-0c65adc9a5c1b5d7c"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.nginx_subnet.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  tags = {
    Name = "nginx-server"
  }
}

resource "aws_instance" "tomcat_server" {
  ami           = "ami-0c65adc9a5c1b5d7c"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.tomcat_subnet.id
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]

  tags = {
    Name = "tomcat-server"
  }
}

resource "aws_instance" "database_server" {
  ami           = "ami-0c65adc9a5c1b5d7c"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.db_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "database-server"
  }
}