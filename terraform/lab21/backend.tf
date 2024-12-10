terraform {
  backend "s3" {
    bucket = "ivolve-remote-backend"
    key    = "ivolve/terraform-tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
