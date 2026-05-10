resource "aws_security_group" "backend_sg" {
  name        = "${var.ENV}-${var.PROJECT_NAME}-backend-sg-group"
  description = "Allow TLS inbound traffic to backend subnet"
  vpc_id      = aws_vpc.ecs_deploymenmt.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-backend-sg-group"  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_to_backend" {
  for_each                     = var.SERVICE_CONFIG
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.webapp_security_group.id
  description                  = "Allow ${each.key} traffic from webapp"   
  from_port                    = each.value.container_port
  to_port                      = each.value.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_to_backend" {
  for_each                     = var.SERVICE_CONFIG
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.backend_sg.id
  description                  = "Allow ${each.key} traffic to all backends"   
  from_port                    = each.value.container_port
  to_port                      = each.value.container_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_backend" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "secrets_manager_endpoint" {
  count = var.enable_secrets_vpc_endpoint ? 1 : 0

  name        = "${var.ENV}-${var.PROJECT_NAME}-secrets-endpoint-sg"
  description = "Security group for Secrets Manager interface endpoint"
  vpc_id      = aws_vpc.ecs_deploymenmt.id
  tags        = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-secrets-endpoint-sg" })

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.backend_subnets
    description = "Allow backend subnets to reach Secrets Manager endpoint"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "allow_redis_self" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.backend_sg.id
  
  # This allows any resource using this SG to talk to others on 6379
  source_security_group_id = aws_security_group.backend_sg.id 
}

resource "aws_vpc_security_group_ingress_rule" "allow_to_redis_from_backend" {
  count             = "${length(var.backend_subnets)}"
  security_group_id = aws_security_group.allow_to_db.id
  cidr_ipv4         = "${element(var.backend_subnets, count.index)}" 
  from_port         = var.REDIS_PORT
  ip_protocol       = "tcp"
  to_port           = var.REDIS_PORT
}

resource "aws_security_group_rule" "allow_internal_cluster_traffic" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_sg.id
  source_security_group_id = aws_security_group.backend_sg.id
}