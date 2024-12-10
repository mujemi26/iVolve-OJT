output "instance_ips" {
  value = {
    for instance in aws_instance.main : 
    instance.tags["Name"] => {
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
    }
  }
}

output "nat_gateway_ip" {
  value = aws_eip.nat.public_ip
}
