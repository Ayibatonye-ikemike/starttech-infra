variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "docker_username" { type = string }
variable "mongo_uri" { type = string }

resource "aws_security_group" "alb" {
  name   = "starttech-alb-sg"
  vpc_id = var.vpc_id
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

resource "aws_security_group" "ec2" {
  name   = "starttech-ec2-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "backend" {
  name               = "starttech-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "backend" {
  name     = "starttech-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_launch_template" "backend" {
  name_prefix   = "starttech-backend-"
  image_id      = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS us-east-1
  instance_type = "t3.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set +e
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker pull ${var.docker_username}/much-to-do-backend:latest
              if [ \$(docker ps -a -q -f name=app) ]; then
                  docker rm -f app
              fi
              set -e
              docker run -d --name app -p 8080:8080 -e MONGO_URI="${var.mongo_uri}" -e PORT="8080" -e HOST="0.0.0.0" ${var.docker_username}/much-to-do-backend:latest
              EOF
  )
}

resource "aws_autoscaling_group" "backend" {
  name                = "starttech-backend-asg"
  target_group_arns   = [aws_lb_target_group.backend.arn]
  vpc_zone_identifier = var.public_subnets # <-- FIXED: Swapped private for public subnets
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}

output "alb_dns" { value = aws_lb.backend.dns_name }
output "ec2_sg_id" { value = aws_security_group.ec2.id }
