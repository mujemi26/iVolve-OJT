# OUTPUT TO RETRIVE VPC ID
output "vpc_id" {
    value = aws_vpc.vpc.id
}

# OUTPUT TO RETRIVE INTERNET GATEWAY ID
output "igw_id" {
    value = aws_internet_gateway.igw.id
}

#OUTPUT TO RETRIVE NAT ID
output "nat_id" {
    value = aws_nat_gateway.nat.id
}


