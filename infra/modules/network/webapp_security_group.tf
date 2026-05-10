

resource "aws_security_group" "service_security_group" {
  name        = "${var.ENV}-${var.PROJECT_NAME}-service-sg"
  description = "Security group for ECS internal services"
  vpc_id      = aws_vpc.ecs_deploymenmt.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-service-sg" })

  dynamic "ingress" {
    for_each = var.internal_alb_security_group_id != "" ? [var.internal_alb_security_group_id] : []
    content {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "Allow HTTP from internal ALB"
    }
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
  vpc_id      = aws_vpc.ecs_deploymenmt.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-webapp-sg" })
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


resource "aws_vpc_security_group_ingress_rule" "webapp_from_https" {
  security_group_id = aws_security_group.webapp_security_group.id
  description       = "Allow HTTPs from the Internet"
  cidr_ipv4         = "0.0.0.0/0"
  
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-webapp-https" })
}