terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.30"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  
}
locals {
  secgr-dynamic-ports = [22, 80, 443]
}

resource "aws_security_group" "prj-sec-grp" {
    name = "prj-docker-sec-grp"
    tags = {
      Name = "prj-docker-sec-grp"
    }
    dynamic "ingress" {
      for_each = local.secgr-dynamic-ports
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      
    }
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
}

  

resource "aws_instance" "prj-docker-instance" {
    ami = data.al2023
    instance_type = var.ec2-instance_type
    key_name = var.key-name
    vpc_security_group_ids = [ aws_security_group.prj-sec-grp.id ]
    tags = {
      Name = "Web Server of Bookstore"
    }
    user_data = base64encode(templatefile("user-data.sh", { user-data-git-token = var.git-token, user-data-git-name = var.git-name, db-password = var.db-password, db-root-password = var.db-root }))
    
  
}

output "myec2-public-ip" {
  value = "http://${aws_instance.docker_instance.public_dns}"
}