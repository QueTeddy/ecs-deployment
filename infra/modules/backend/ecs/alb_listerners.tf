resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }

  tags = var.COMMON_TAGS
}

resource "aws_lb_listener_rule" "service_routing" {
  for_each     = var.SERVICE_CONFIG
  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.alb_target_group.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.applications[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.alb_target_group.path_pattern
    }
  }

  tags = merge(
    var.COMMON_TAGS,
    { Name = "${var.ENV}-${var.PROJECT_NAME}-service-rule" }
  )
}

resource "aws_lb_target_group" "applications" {
  for_each = var.SERVICE_CONFIG

  name        = "${var.ENV}-${each.key}-TG"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = each.value.alb_target_group.health_check_path
  }

  
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-app-tg" })
}
