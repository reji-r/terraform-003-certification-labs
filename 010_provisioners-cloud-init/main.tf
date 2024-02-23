terraform {
  cloud {
    organization = "cloud-dragons"

    workspaces {
      name = "provisioners"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = "vpc-08fac5af742e1a149"
}

data "template_file" "user_data" {
  template = file(("./userdata.yaml"))
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzdwDj+ah69rtgqkX7QCvQrSp5nesucWUlNhq0uIZIh5MyA09jPJtMI9YuCYKPGwpVhfrCCmQ5BxiQLOGGNr4X3oP80DWeXTZHqiWaNurwIubf44EBFpuqwlQofKLtWhC63OERAeIQoOhcwoGM+LLOgYdZD0U6DROzR/ttHd/jlK1ELMBTYTIfh2VHxn/OVJg+lxkUbMAYSAc9syzmhC4BxwjCiem7vVvsZXkTOEOba6dkeuUfQds9Izx8A7bYJv75JjhWv7o1DI4dDOF4+PAyL0/ZP5mIWwUe+YaAj+RydT5sHkE3Z4Qg9Giv5gJtBhUzPAwnLRmmSYlAMhA/vB/AtYjKcU/eEVDWHAOb129jqn3CjhgOleWYE4BMrVm+3+5nvBKYwj+7uQmH1SRrd7IDGQygt1P1/xJSvtQWAvo34qoo6JWxAHshOOiUWvflKDPfhBCNNUQjKeuvjluVkS0rhfP+PialLZFeestL7cXTbbZd0dNbBDAL05Ze9HzaXSE= rejiprn@Reji-Laptop"
}

resource "aws_instance" "my_server" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered


  tags = {
    Name = "MyAppServer"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyAppServer security group"
  vpc_id      = data.aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "82.24.44.124/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH"
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}