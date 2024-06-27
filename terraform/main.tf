provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k6_instance" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.main.*.id, count.index)
  security_groups = [aws_security_group.instance.name]

  tags = {
    Name = "k6-instance-${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              curl -s https://dl.k6.io/key.gpg | sudo apt-key add -
              echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
              sudo apt update
              sudo apt install k6 -y
              EOF

  provisioner "local-exec" {
    command = "echo ${aws_instance.k6_instance[count.index].public_ip} >> inventory"
  }
}

output "instance_ips" {
  value = aws_instance.k6_instance.*.public_ip
}

