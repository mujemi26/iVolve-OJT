variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "subnets" {
  type = list(object({
    name               = string
    cidr_block         = string
    availability_zone  = string
    is_public         = bool
  }))
  default = [
    {
      name              = "public"
      cidr_block       = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      is_public        = true
    },
    {
      name              = "private"
      cidr_block       = "10.0.2.0/24"
      availability_zone = "us-east-1a"
      is_public        = false
    }
  ]
}

variable "route_tables" {
  type = list(object({
    name = string
    routes = list(object({
      cidr_block   = string
      gateway_key  = string
    }))
  }))
  default = [
    {
      name = "public-rt"
      routes = [
        {
          cidr_block  = "0.0.0.0/0"
          gateway_key = "igw"
        }
      ]
    },
    {
      name = "private-rt"
      routes = [
        {
          cidr_block  = "0.0.0.0/0"
          gateway_key = "nat"
        }
      ]
    }
  ]
}

variable "instances" {
  type = list(object({
    name       = string
    subnet_key = string
    user_data  = string
  }))
  default = [
    {
      name       = "nginx-server"
      subnet_key = "public"
      user_data  = <<-EOF
                   #!/bin/bash
                   yum update -y
                   yum install nginx -y
                   systemctl start nginx
                   systemctl enable nginx
                   EOF
    },
    {
      name       = "apache-server"
      subnet_key = "private"
      user_data  = <<-EOF
                   #!/bin/bash
                   yum update -y
                   yum install httpd -y
                   systemctl start httpd
                   systemctl enable httpd
                   EOF
    }
  ]
}

variable "security_group_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
