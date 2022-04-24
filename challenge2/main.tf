
provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "db" {
  ami = "ami-064d33fad222a1c4a"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Server"
  }
}

resource "aws_instance" "web" {
  ami = "ami-064d33fad222a1c4a"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.name]
  user_data = file("server-script.sh")

  tags = {
    Name = "Web Server"
  }
}

resource "aws_eip" "elasticip" {
  instance = aws_instance.web.id
}

variable "ingressrules" {
  type = list(number)
  default = [80, 443]
}

variable "egressrules" {
  type = list(number)
  default = [80, 443]
}

resource "aws_security_group" "webtraffic" {
  name = "Allow Web Traffic"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egressrules
    content {
      from_port = port.value
      to_port = port.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

output "dbserver_privateip" {
  value = aws_instance.db.private_ip
}

output "webserver_publicip" {
  value = aws_eip.elasticip.public_ip
}
