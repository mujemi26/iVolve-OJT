output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.database.endpoint
}

output "ssh_connection_string" {
  value = "ssh -i /Users/muhammadjimmy/Desktop/ivolve/terraform/lab17/ansible-ec2.pem ec2-user@${aws_instance.web_server.public_ip}"
}
