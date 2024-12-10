provider "aws" {
  region = var.aws_region
}

locals {
  subnet_map = { for subnet in aws_subnet.main : subnet.tags["Name"] => subnet.id }
  gateway_map = {
    igw = aws_internet_gateway.main.id
    nat = aws_nat_gateway.main.id
  }
}

resource "aws_vpc" "existing" {
  # Configuration will be imported
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.existing.id
  tags   = merge(var.common_tags, { Name = "main-igw" })
}

resource "aws_subnet" "main" {
  count                   = length(var.subnets)
  vpc_id                  = aws_vpc.existing.id
  cidr_block             = var.subnets[count.index].cidr_block
  availability_zone      = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = var.subnets[count.index].is_public

  tags = merge(var.common_tags, {
    Name = "${var.subnets[count.index].name}-subnet"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "nat-eip" })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.subnet_map["public-subnet"]
  tags          = merge(var.common_tags, { Name = "main-nat" })
}

resource "aws_route_table" "main" {
  count  = length(var.route_tables)
  vpc_id = aws_vpc.existing.id

  dynamic "route" {
    for_each = var.route_tables[count.index].routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = route.value.gateway_key == "igw" ? local.gateway_map["igw"] : null
      nat_gateway_id = route.value.gateway_key == "nat" ? local.gateway_map["nat"] : null
    }
  }

  tags = merge(var.common_tags, {
    Name = var.route_tables[count.index].name
  })
}

resource "aws_route_table_association" "main" {
  count          = length(var.subnets)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main[var.subnets[count.index].is_public ? 0 : 1].id
}

resource "aws_security_group" "common" {
  name        = "common-sg"
  description = "Common security group for EC2 instances"
  vpc_id      = aws_vpc.existing.id

  dynamic "ingress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.common_tags, { Name = "common-sg" })
}

resource "aws_instance" "main" {
  count                  = length(var.instances)
  ami                    = "ami-0453ec754f44f9a4a"  # Replace with your AMI
  instance_type         = "t2.micro"
  subnet_id             = local.subnet_map["${var.instances[count.index].subnet_key}-subnet"]
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.common.id]
  user_data             = var.instances[count.index].user_data

  tags = merge(var.common_tags, {
    Name = var.instances[count.index].name
  })
}
