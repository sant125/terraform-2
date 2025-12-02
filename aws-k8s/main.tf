provider "aws" {
  region = var.aws_region
}

# Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group - Master
resource "aws_security_group" "master" {
  name = "k8s-master-sg"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API Server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd
  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  # Kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort
  ingress {
    from_port   = 30000
    to_port     = 32767
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

# Security Group - Worker
resource "aws_security_group" "worker" {
  name = "k8s-worker-sg"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort
  ingress {
    from_port   = 30000
    to_port     = 32767
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

# Spot Instance - Master
resource "aws_spot_instance_request" "master" {
  ami                            = data.aws_ami.ubuntu.id
  instance_type                  = var.instance_type
  spot_price                     = var.spot_price
  wait_for_fulfillment           = true
  spot_type                      = "persistent"
  instance_interruption_behavior = "stop"
  key_name                       = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.master.id]
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "k8s-master"
  }
}

# Spot Instance - Worker
resource "aws_spot_instance_request" "worker" {
  count = var.worker_count

  ami                            = data.aws_ami.ubuntu.id
  instance_type                  = var.instance_type
  spot_price                     = var.spot_price
  wait_for_fulfillment           = true
  spot_type                      = "persistent"
  instance_interruption_behavior = "stop"
  key_name                       = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.worker.id]
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}
