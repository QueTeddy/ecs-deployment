resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }

  tags = var.COMMON_TAGS
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.WEBAPP_CERT_ARN
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Service Not Found"
      status_code  = "404"
    }
  }

  tags = var.COMMON_TAGS
}

resource "aws_lb_listener_rule" "service_routing" {
  for_each     = var.SERVICE_CONFIG
  listener_arn = aws_lb_listener.https.arn
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

  name        = "${var.ENV}-${var.PROJECT_NAME}-${each.key}-TG"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = each.value.alb_target_group.health_check_path
  }

  
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-app-tg" })
}

# resource "aws_lb_listener_rule" "cors_preflight" {
#   for_each     = var.SERVICE_CONFIG
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 1

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.applications[each.key].arn
#   }

#   condition {
#     http_request_method {
#       values = ["OPTIONS"]
#     }
#   }
# }



# resource "aws_lb_listener_rule" "cors_preflight" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 1

#   action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#       custom_response_headers = {
#         "Access-Control-Allow-Origin" = "https://${var.WEBAPP_DNS}, http://localhost:*"
#         "Access-Control-Allow-Methods" = "GET, POST, OPTIONS, PUT, DELETE, PATCH"
#         "Access-Control-Allow-Headers" = "Content-Type, Authorization"
#       }
#     }
#   }

#   condition {
#     http_request_method {
#       values = ["OPTIONS"]
#     }
#   }
# }
# }

# resource "aws_lb_listener_rule" "service_routing" {
#   for_each     = var.SERVICE_CONFIG
#   listener_arn = aws_lb_listener.https.arn
#   priority     = each.value.alb_target_group.priority

#   action {
#     type = "forward"
#     forward {
#       target_group {
#         arn = aws_lb_target_group.applications[each.key].arn
#       }
#     }
#   }

#   action {
#     type  = "forward"
#     order = 1

#     header_modification {
#       header_name  = "Access-Control-Allow-Origin"
#       header_value = "https://${var.WEBAPP_DNS}"
#     }
    
#     header_modification {
#       header_name  = "Access-Control-Allow-Credentials"
#       header_value = "true"
#     }
#   }

#   condition {
#     path_pattern {
#       values = each.value.alb_target_group.path_pattern
#     }
#   }

#   tags = merge(
#     var.COMMON_TAGS,
#     { Name = "${var.ENV}-${var.PROJECT_NAME}-${each.key}-service-rule" }
#   )
# }