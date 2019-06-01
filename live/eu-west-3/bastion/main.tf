//connections.tf
provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "main" {
  cidr_block           = "172.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mainVPC"
  }
}

//variables.tf
variable "ami_name" {}
variable "ami_id" {}
variable "ami_key_pair_name" {}


/*
 **********
 * Subnet *
 **********
 */
resource "aws_subnet" "subnet-bastion" {
  availability_zone = "eu-west-3c"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.2.8.0/24"

  tags = {
    Name = "subnetBastion"
  }
}

resource "aws_security_group" "bastion-all-ssh" {
  name   = "bastion-all-ssh"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//servers.tf
resource "aws_instance" "bastion_instance" {
  ami             = "${var.ami_id}"
  instance_type   = "t2.micro"
  key_name        = "${var.ami_key_pair_name}"
  subnet_id       = "${aws_subnet.subnet-bastion.id}"
  security_groups = ["${aws_security_group.bastion-all-ssh.id}"]

  tags {
    Name = "EC2 FOR BASTION"
  }
}

//gateways.tf
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "test-env-gw"
  }
}

//subnets.tf
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }

  tags {
    Name = "bastion-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-bastion.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}

resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.bastion_instance.id}"
  vpc      = true
}
