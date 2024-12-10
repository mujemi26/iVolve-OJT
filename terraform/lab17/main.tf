# Configure AWS Provider
provider "aws" {
  region = "us-east-1"  
}

# Data block to fetch existing VPC
data "aws_vpc" "ivolve" {
  tags = {
    Name = "ivolve"
  }
}

# Data block to fetch existing key pair
data "aws_key_pair" "existing_key" {
  key_name = "ansible-ec2"
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.ivolve.id

  tags = {
    Name = "ivolve-igw"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.ivolve.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ivolve-public-rt"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create 2 subnets (public and private)
resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.ivolve.id
  cidr_block              = "10.0.1.0/24"  
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ivolve-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.ivolve.id
  cidr_block        = "10.0.2.0/24"  
  availability_zone = "us-east-1b"

  tags = {
    Name = "ivolve-private-subnet"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.ivolve.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.ivolve.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

# Create EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0453ec754f44f9a4a"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = {
    Name = "ivolve-web-server"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ec2-ip.txt"
  }
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "ivolve-rds-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

  tags = {
    Name = "ivolve RDS subnet group"
  }
}

# Create RDS Instance
resource "aws_db_instance" "database" {
  identifier           = "ivolve-database"
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  manage_master_user_password = true
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  skip_final_snapshot = true

  tags = {
    Name = "ivolve-database"
  }
}
