provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-04e5276ebb8451442"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
  associate_public_ip_address = true
  key_name = "silhh-key"
  tags = {
    Name = "my-ubuntu"
  }
}

resource "aws_launch_configuration" "silhh" {
  image_id        = "ami-04e5276ebb8451442"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required with an autoscaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "web1"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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
resource "aws_key_pair" "silhh-key" {
  key_name   = "silhh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhRWeZ8bVIf0NtRzqsetB50YzgIkgBY0FFSBfCwLTc41KHwF+t0Dz0oUQFU9hHqOTABPUMFqX/o3n9fwjYj6rpPszTYF29EPPliUSM54Fd7vATOgWAUygBOEdVpBu6sDO3soms6+5PETgyu2FT6eWFvPXqTeiCHo1ShxrTDEgoEQPZslXeXc+hnID6xE1gQlh9TtQqkRhUBC6KOiXUCIT3pCHG7WlV+BLe2KU/4OaGLyE3v5okspcegYYtbRuj2s2t8sMY+zwU8dHMr+yJJHJ7bnPBuOdUF3qzPAyyyTfV9NG2ZUbLx+XZHpOnlbDy5yGAKsmQWmSD45Xnr51RAQQr root@192.168.110.132"
}
