# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"

  #   backend "s3" {
  #   region         = "us-west-2"
  #   bucket         = "account-tfstate-110742927162"
  #   key            = "account-tfstate/terraform.tfstate"
  #   dynamodb_table = "account-tfstate"
  # }

  backend "remote" {
    organization = "mwong-tamu"
    workspaces {
      prefix = "learn-terraform-github-actions"
    }
  }
}

}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}


locals {
  vpc_id = "vpc-06bb94323b5d9109e"
  subnets = {
    private_1 = "subnet-0a08393c5a03f8f43"
    private_2 = "subnet-06e7c9446e45c5094"
    # campus_1  = "subnet-01f04d36af54c124a"
    # campus_2  = "subnet-0f6e312e07a83043f"
    # private_1 = "subnet-0609f74a8ee13fcfd"
    # private_2 = "subnet-0e021f0d38af9e3c1"
    # public_1  = "subnet-0bb094db50bd8d4bc"
    # public_2  = "subnet-03229bee9a2e62b48"
  }
#   route53_zone_id = "Z04664691DWPKW2YOV3BA"
#   ansible_check   = var.ansible_check == true ? "--check" : ""
#   owners = [
#     "8fbbc54f-91e1-4261-b571-1ec3e3e78f08", # jrafferty-admin
#     "4536b843-8f73-4029-9c0d-f8c673d3d202", # jiahouzhou
#     "71c64be2-3f0d-461b-b50d-8c6f569a0412", # jmartz
#     "b3743709-f476-4784-94ef-8137199a953d", # mwong
#     "b4b12529-fda4-4925-bda2-17ef23e51dc5"  # achen
#   ]
#   admin_unit_id = "e8c7d89b-2757-4820-a04b-904b653f8a2a" # it-svc-assetworks
}

# Original code below

resource "random_pet" "sg" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
}
