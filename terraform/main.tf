// main.tf

provider "aws" {
  region = var.aws_region
}

// Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

// Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

// Create public subnet with public IP assignment
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)  // Example: 10.0.0.0/24 for the first subnet
  availability_zone = element(var.availability_zones, 0)
  
  map_public_ip_on_launch = true  // Ensure instances launched in this subnet get a public IP
}

// Associate internet gateway with the VPC
resource "aws_vpc_attachment" "main_igw_attachment" {
  vpc_id       = aws_vpc.main.id
  internet_gateway_id = aws_internet_gateway.igw.id
}

// Create instances in the public subnet with SSH access enabled
resource "aws_instance" "k6_instance" {
  count           = 3
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public.id  // Use the public subnet for instances
  key_name        = "techkeyjune"
  associate_public_ip_address = true  // Ensures instances get a public IP

  // Security group allowing SSH access from anywhere
  security_groups = [aws_security_group.instance_sg.id]

  tags = {
    Name = "k6-instance-${count.index}"
  }

  // Example user_data script for instance initialization
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

// Security group allowing SSH access from anywhere
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  // Ingress rule allowing SSH traffic from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
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

// Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  // Use the internet gateway to route traffic outside
  }

  tags = {
    Name = "public-route-table"
  }
}

// Associate the public route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

// Generate a file containing only the public IP addresses of the instances
resource "local_file" "instance_ips" {
  content  = join("\n", aws_instance.k6_instance[*].public_ip)
  filename = "${path.module}/instance_ips.txt"
}
