terraform {
  backend "s3" {
    bucket = "mds-2018"
    encrypt = true
    key = "live/eu-west-3/bastion/terraform.state"
    region = "eu-west-3"
  }
}