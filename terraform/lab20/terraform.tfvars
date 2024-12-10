vpc_id        = "vpc-01d2e14b8b1ee0d30"    # Your VPC ID
key_pair_name = "ansible-ec2"   # Your key pair name

common_tags = {
  Environment = "dev"
  Project     = "demo"
  Terraform   = "true"
}
