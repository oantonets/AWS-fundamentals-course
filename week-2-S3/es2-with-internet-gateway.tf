# config to create ec2 instance and connect to internet gateway. It can be used to access S3(with correct IAM profile)
provider "awscc" {
  region                   = "us-east-1"
  shared_credentials_files = ["./.credentials"] # path to file with AWS credentials
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
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

resource "aws_security_group" "HTTP" {
  name        = "HTTP"
  description = "Allows HTTP connection to the instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
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

resource "aws_security_group" "ping" {
  name        = "Ping"
  description = "Allows ping security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Ping"
    protocol    = "ICMP"
    from_port   = 8
    # to_port 0 is not obvious at all!
    to_port     = 0
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
  security_groups = [aws_security_group.SSH.id, aws_security_group.ping.id, aws_security_group.HTTP.id]

  attachment {
    instance     = aws_instance.ec2_instance.id
    device_index = 1
  }
}

resource "aws_instance" "ec2_instance" {
  instance_type               = "t2.micro"
  ami                         = "ami-09d3b3274b6c5d4aa"
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.SSH.id, aws_security_group.ping.id, aws_security_group.HTTP.id]
  key_name                    = "test-key-pair"
  associate_public_ip_address = true
  iam_instance_profile        = "s3_read_only"
  user_data_replace_on_change = true
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
