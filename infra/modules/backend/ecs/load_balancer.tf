resource "aws_lb" "ecs_alb" {
  name               = "${var.ENV}-${var.PROJECT_NAME}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.WEBAPP_SECURITY_GROUP_ID]
  subnets            = var.WEBAPP_SUBNETS 
  }


resource "aws_security_group" "alb_sg" {
  name        = "${var.ENV}-${var.PROJECT_NAME}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Controls access to the ALB"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}