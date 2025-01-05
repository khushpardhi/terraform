provider "aws" {
  region = "ap-southeast-2"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# Create a Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
  tags = {
    Name = "MySubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Create a Route Table and Route
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a Security Group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

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

  tags = {
    Name = "MySecurityGroup"
  }
}

# Create a Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtxBVoV7bOxR46x9hvlC9fWyhkD1xPcPLm9ZpF2qjpm3OLs5tJUuoV6LObiXSAXhzncrohIaCeBT1DiNxRzKmwY3nJxXzhS8srK0//XZunKAKwXGg1ADXLW6JScahtYP5M/PgP76HVwBkd7sX91eq9nYF01YdOzx4Ya0ASKvmd48RRAIoe2FmNbICOHtP9Xmbix0jxFZGNEV+ZH2MRrLloFm0vUJLfAMxFgMCrk5MSaunvJ3UXxhqZvS09v62KZJtK3CxiwDOyyYJHT1vYWq39U+uJZwGr5zKxC6VoTcvZwZiQRX9yss2Jjdd627F6jLn42WMJC1ez3mSArAiGtB7R ubuntu@ip-172-31-9-128"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-003f5a76758516d1e"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [
    aws_security_group.my_sg.id 
  ]
  key_name = aws_key_pair.my_key.key_name

  # User Data for deployment
  user_data = <<-EOF
              #!/bin/bash
              echo "Updating the system..."
              sudo apt-get update -y

              echo "Cloning the repository..."
              git clone https://github.com/khushpardhi/wanderlust.git /home/ubuntu/wanderlust

              echo "Installing Docker..."
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              docker --version

              echo "Starting Docker..."
              sudo systemctl start docker
              sudo systemctl enable docker

              echo "Installing Docker Compose..."
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              echo "Navigating to the cloned repository..."
              cd /home/ubuntu/wanderlust

              echo "Building Docker images..."
              sudo docker-compose build

              echo "Starting containers with Docker Compose..."
              sudo docker-compose up -d
              EOF

  tags = {
    Name = "my_ec2"
  }
}


