terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

provider "aws" {
  region = "eu-north-1" # Stockholm
}

# Data source to get the latest Ubuntu 20.04 AMI in the specified region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group to allow SSH and HTTP traffic
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow SSH and custom HTTP traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP on port 8080 from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http_8080"
    Environment = var.environment
  }
}

# EC2 Instance definition
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "devops play"

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # Cloud-init script to install Docker and Docker Compose only
  user_data = <<-EOF
              #!/bin/bash
              # Update and install prerequisites
              apt-get update -y
              apt-get install -y \
                  apt-transport-https \
                  ca-certificates \
                  curl \
                  gnupg \
                  lsb-release

              # Add Docker's official GPG key
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

              # Set up the stable repository
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Install Docker Engine
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io

              # Install Docker Compose
              LATEST_COMPOSE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
              curl -L "https://github.com/docker/compose/releases/download/$${LATEST_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Add ubuntu user to docker group
              usermod -aG docker ubuntu

              # Create directory for application deployment
              mkdir -p /opt/app
              chown ubuntu:ubuntu /opt/app
              EOF

  tags = {
    Name = "WebServerInstance"
    Environment = var.environment
  }
}