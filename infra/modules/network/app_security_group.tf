

resource "aws_security_group" "service_security_group" {
  name        = "${var.ENV}-${var.PROJECT_NAME}-service-sg"
  description = "Security group for ECS internal services"
  vpc_id      = aws_vpc.ecs_deployment.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-service-sg" })

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webapp_security_group" {
  name        = "${var.ENV}-${var.PROJECT_NAME}-webapp-sg"
  description = "Security group for ECS public web services (ALB source)"
  vpc_id      = aws_vpc.ecs_deployment.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-webapp-sg" })
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_vpc_security_group_ingress_rule" "webapp_from_internet" {
  security_group_id = aws_security_group.webapp_security_group.id
  description       = "Allow HTTP from the Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-webapp-http" }) 
}

