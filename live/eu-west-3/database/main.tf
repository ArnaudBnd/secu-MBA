/*
 ********************** Configurations **********************
 */
variable public_key_path {
 default = "~/.ssh/id_rsa.pub"
}

variable db_name {
 default = "mba"
}

variable db_username {
 default = "mba_user"
}

variable db_password {
 default = "!U[=nnP[6Kxg~d3?"
}

variable "ami_name" {}
variable "ami_id" {}
variable "ami_key_pair_name" {}

/*
 ************************************************************
 */

//connections.tf
provider "aws" {
  region = "eu-west-3"
}

data "aws_vpc" "main" {
  tags {
    Name = "mainVPC"
  }
}

data "aws_instance" "bastionInstance" {
  instance_tags {
    Name = "EC2 FOR BASTION"
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/files/config.json")}"

  vars = {
    hostDB = "${aws_db_instance.default.endpoint}"
    userDB = "${var.db_username}"
    passDB = "${var.db_password}"
    nameDB = "${var.db_name}"
  }
}

/*
 **********
 * Subnet *
 **********
 */
resource "aws_subnet" "main" {
  availability_zone = "eu-west-3a"
  vpc_id            = "${data.aws_vpc.main.id}"
  cidr_block        = "172.2.1.0/24"

  tags = {
    Name = "subnetBDD1"
  }
}

resource "aws_subnet" "second" {
  availability_zone = "eu-west-3b"
  vpc_id            = "${data.aws_vpc.main.id}"
  cidr_block        = "172.2.2.0/24"

  tags = {
    Name = "subnetBDD2"
  }
}
/*
 **************
 * End subnet *
 **************
 */

resource "aws_db_subnet_group" "test" {
  name       = "main"
  subnet_ids = ["${aws_subnet.main.id}", "${aws_subnet.second.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

/*
 ******************
 * security-group *
 ******************
 */
 resource "aws_security_group" "first" {
  name        = "first"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    cidr_blocks = [
      "172.2.0.0/16",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/*
 **********************
 * End security-group *
 **********************
 */

 resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "9.6.3"
  instance_class         = "db.t2.micro"
  name                   = "${var.db_name}"
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  availability_zone      = "eu-west-3a"
  db_subnet_group_name   = "${aws_db_subnet_group.test.id}"
  vpc_security_group_ids = ["${aws_security_group.first.id}"]
  skip_final_snapshot    = true
}

resource "aws_instance" "web" {
  ami                    = "${var.ami_id}"
  instance_type          = "t2.micro"
  key_name               = "amazon_pub"
  subnet_id              = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${aws_security_group.first.id}"]

  tags = {
    Name = "EC2"
  }

  connection {
    // bastion
    bastion_host        = "${data.aws_instance.bastionInstance.public_dns}"
    bastion_host_key    = "amazon_pub"
    bastion_private_key = "${file("~/.ssh/amazon_pub")}"
    bastion_user        = "ubuntu"

    // ursho
    type        = "ssh"
    user        = "ubuntu"
    host        = "${aws_instance.web.private_ip}"
    private_key = "${file("~/.ssh/amazon_pub")}"
    timeout     = "30s"
  }

  provisioner "file" {
    source      = "./files/config.json"
    destination = "/home/ubuntu/config/config.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start ursho.service",
      "sudo systemctl enable ursho.service",
    ]
  }
}



