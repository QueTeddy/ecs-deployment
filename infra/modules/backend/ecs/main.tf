locals {
  env_settings = {
    dev = {
      max_capacity = 200 
      min_healthy  = 100
      spot_weight  = 100
      fargate_base = 0 
    }
  }

  current = local.env_settings[var.ENV]
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = lower("${var.ENV}-${var.PROJECT_NAME}-cluster")
  tags = var.COMMON_TAGS
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE_SPOT"]

}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  for_each                 = var.SERVICE_CONFIG
  family                   = lower("${var.ENV}-${var.PROJECT_NAME}-${each.key}-service")
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = each.value.memory
  cpu                      = each.value.cpu

  container_definitions = jsonencode([
    {
      name         = each.value.name
      image        = "${var.ACCOUNT_ID}.dkr.ecr.${var.REGION}.amazonaws.com/${lower(var.ENV)}-${lower(var.PROJECT_NAME)}-${lower(each.value.name)}:latest"
      cpu          = each.value.cpu
      memory       = each.value.memory
      essential    = true
      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.host_port
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${each.value.container_port}${each.value.alb_target_group.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = "${var.ENV}-${var.PROJECT_NAME}-${lower(each.key)}-logs"
          awslogs-region        = "${var.REGION}"
          awslogs-stream-prefix = "${var.ENV}-${var.PROJECT_NAME}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "private_service" {
  for_each = var.SERVICE_CONFIG

  name            = "${var.ENV}-${var.PROJECT_NAME}-${each.value.name}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition[each.key].arn
  desired_count   = each.value.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = local.current.spot_weight
  }

  deployment_maximum_percent         = local.current.max_capacity
  deployment_minimum_healthy_percent = local.current.min_healthy

  availability_zone_rebalancing = "DISABLED"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.BACKEND_SUBNETS
    assign_public_ip = each.value.is_public == true ? true : false
    security_groups  = [var.BACKEND_SECURITY_GROUP]
  }

  dynamic "load_balancer" {
    for_each = contains(keys(aws_lb_target_group.applications), each.key) ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.applications[each.key].arn
      container_name   = each.value.name
      container_port   = each.value.container_port
    }
  }
}