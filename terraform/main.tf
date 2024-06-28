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
  
  map_public_ip_on_launch = true  # Ensure instances launched in this subnet get a public IP
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id

  // Ingress rules allow SSH and HTTP traffic from anywhere
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

  // Egress rule allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k6_instance" {
  count           = 3
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = element(aws_subnet.main.*.id, count.index)
  security_groups = [aws_security_group.instance.id]
  key_name        = "techkeyjune"
  associate_public_ip_address = true  # Ensures instances get a public IP

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
}
