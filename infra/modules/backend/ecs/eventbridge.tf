resource "aws_cloudwatch_event_rule" "service_ecr_push" {
  for_each    = var.SERVICE_CONFIG
  name        = lower("${var.ENV}-${var.PROJECT_NAME}-${each.value.name}-ecr-push")
  description = "Trigger ECS task on new ECR image push for ${each.value.name}"

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = ["${lower(var.ENV)}-${lower(var.PROJECT_NAME)}-${lower(each.value.name)}"]
      image-tag       = ["latest"]
    }
  })
}

resource "aws_cloudwatch_event_target" "service_ecs_task" {
  for_each  = var.SERVICE_CONFIG
  rule      = aws_cloudwatch_event_rule.service_ecr_push[each.key].name
  target_id = "${each.key}-deploy-task"
  arn       = aws_ecs_cluster.ecs_cluster.arn
  role_arn  = aws_iam_role.eventbridge_ecs_invoke.arn
  dead_letter_config {
    arn = aws_sqs_queue.eventbridge_dlq.arn
  }

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.ecs_task_definition[each.key].arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.BACKEND_SUBNETS
      security_groups  = [var.BACKEND_SECURITY_GROUP]
      assign_public_ip = each.value.is_public == true ? true : false
    }
  }
}

resource "aws_iam_role" "eventbridge_ecs_invoke" {
  name               = lower("${var.ENV}-${var.PROJECT_NAME}-eventbridge-invoke-role")
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "eventbridge_run_task_policy" {
  name = "${var.ENV}-${var.PROJECT_NAME}-eventbridge-run-task-policy"
  role = aws_iam_role.eventbridge_ecs_invoke.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask"]
        Resource = ["*"]
        Condition = {
          ArnEquals = {
            "ecs:cluster" = aws_ecs_cluster.ecs_cluster.arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# The Dead Letter Queue
resource "aws_sqs_queue" "eventbridge_dlq" {
  name = lower("${var.ENV}-${var.PROJECT_NAME}-ecs-deploy-dlq")
  message_retention_seconds = 86400 
}

resource "aws_sqs_queue_policy" "dlq_policy" {
  queue_url = aws_sqs_queue.eventbridge_dlq.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = ["${aws_sqs_queue.eventbridge_dlq.arn}"]
      }
    ]
  })
}