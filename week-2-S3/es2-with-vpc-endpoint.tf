# config to private and public visible instances. Private instance uses vpc_endpoint to create "direct" connect to s3 service
# without leaving vpc network though internet gateway. Public one is needed just to show that connection is working.
# To make it work you'll need to add ssh key to ssh storage and connect to the public instance via "ssh -A user@ip" address.
# This will allow key to be available to the private instance.

provider "awscc" {
  region                   = "us-east-1"
  shared_credentials_files = ["./.credentials"] # path to file with AWS credentials
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  service_name    = "com.amazonaws.us-east-1.s3"
  vpc_id          = aws_vpc.vpc.id
  route_table_ids = [aws_route_table.route_table.id, aws_route_table.route_table_private.id]
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet_private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_internet_gateway" "gateway" {
}

resource "aws_route" "public_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_table.id
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_internet_gateway_attachment" "gateway_attachment" {
  internet_gateway_id = aws_internet_gateway.gateway.id
  vpc_id              = aws_vpc.vpc.id
}

resource "aws_security_group" "SSH" {
  name        = "SSH"
  description = "Allows SSH connection to the instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_network_interface" "network_interface" {
  subnet_id       = aws_subnet.subnet.id
  security_groups = [aws_security_group.SSH.id]

  attachment {
    instance     = aws_instance.ec2_instance.id
    device_index = 1
  }
}

resource "aws_instance" "ec2_instance" {
  instance_type               = "t2.micro"
  ami                         = "ami-09d3b3274b6c5d4aa"
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.SSH.id]
  key_name                    = "test-key-pair"
  iam_instance_profile   = "s3_read_only"
  associate_public_ip_address = true
  user_data              = <<-EOF
    aws s3 cp s3://lohika-oantonets-2022/cal.txt ~/
  EOF
}

resource "aws_instance" "ec2_instance_private" {
  instance_type          = "t2.micro"
  ami                    = "ami-09d3b3274b6c5d4aa"
  subnet_id              = aws_subnet.subnet_private.id
  vpc_security_group_ids = [aws_security_group.SSH.id]
  key_name               = "test-key-pair"
  iam_instance_profile   = "s3_read_only"
  user_data                   = <<EOF
    #!/bin/bash
    echo "Navigating to home directory"
    cd /home/ec2-user
    echo "Copy cal.txt from s3 to current directory"
    aws s3 cp s3://lohika-oantonets-2022/cal.txt ./
  EOF
  # lohika-oantonets-2022 is the name of bucket created via init-s3.sh
  # cal.txt file created via init-s3.sh
}

output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "ec2_instance_private_ip" {
  value = aws_instance.ec2_instance_private.private_ip
}
