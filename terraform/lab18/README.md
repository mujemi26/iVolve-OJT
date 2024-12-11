<h1>Terraform Modules</h1>

    • Create VPC with 2 public subnets in main.tf file.
    • Create EC2 module to create 1 EC2 with Nginx installed on it using user data.
    • Use this module to deploy 1 EC2 in each subnet.

> ## We will start with Main infrastructure file 

```
# This Terraform code creates a basic AWS networking infrastructure with two EC2 instances.


provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# EC2 Instance in first subnet
module "ec2_instance_1" {
  source      = "./modules/ec2"
  subnet_id   = aws_subnet.public_1.id
  vpc_id      = aws_vpc.main.id
  name_prefix = "instance1"
}

# EC2 Instance in second subnet
module "ec2_instance_2" {
  source      = "./modules/ec2"
  subnet_id   = aws_subnet.public_2.id
  vpc_id      = aws_vpc.main.id
  name_prefix = "instance2"
}




# This setup provides a highly available infrastructure across two availability zones (1a and 1b), with each EC2 instance having internet access through the internet gateway.
```

> ## 2. Now we will create EC2 Module file

```
# This Terraform code that creates an EC2 instance and its security group:


resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "${var.name_prefix}-security-group"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0453ec754f44f9a4a"  
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "${var.name_prefix}-nginx-server"
  }
}


# This setup creates a basic web server that:

   - Is accessible via HTTP (port 80) for web traffic

   - Can be managed via SSH (port 22)

   - Automatically installs and starts Nginx when launched

   - Has unrestricted outbound access to the internet
```

> ## 3. EC2 Module Variables file :

```
# This code shows three Terraform variable declarations that are used as inputs for an EC2 module:


variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be used in resource names"
  type        = string
}
```

> ## 4 Finally let's apply this configuration

```
1. Initialize Terraform (if you haven't already):

    terraform init

2. Format your code (optional but recommended):

    terraform fmt

3. Validate the configuration :

    terraform validate

4. Review the execution plan :

    terraform plan

5. Apply the configuration :

    terraform apply

```
