resource "aws_ecs_task_definition" "redis" {
  family                   = "${var.ENV}-${var.PROJECT_NAME}-redis-service"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name  = "redis-service"
      image = "redis:7-alpine" 
      cpu   = 256
      memory = 512
      essential = true
      
      portMappings = [
        {
          containerPort = var.REDIS_PORT
          hostPort      = var.REDIS_PORT
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "REDIS_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.redis_password.arn}:redis_password::"
        }
      ]

      command = [
        "sh", "-c",
        "redis-server --port ${var.REDIS_PORT} --maxmemory 400mb --requirepass $REDIS_PASSWORD"
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "redis-cli ping || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.ENV}-${var.PROJECT_NAME}-redis-logs"
          "awslogs-region"        = "${var.REGION}"
          "awslogs-stream-prefix" = "${var.ENV}-${var.PROJECT_NAME}-redis"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "redis_service" {
  name            = "${var.ENV}-${var.PROJECT_NAME}-redis"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.BACKEND_SUBNETS
    assign_public_ip = false
    security_groups  = [var.BACKEND_SECURITY_GROUP]
  }
  
  service_registries {
    registry_arn = aws_service_discovery_service.redis_discovery.arn
  }
}



#   health_check_custom_config {
#     failure_threshold = 1
#   }

