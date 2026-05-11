resource "aws_lb" "ecs_alb" {
  name               = "${var.ENV}-${var.PROJECT_NAME}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.WEBAPP_SECURITY_GROUP_ID]
  subnets            = var.WEBAPP_SUBNETS 
  }

