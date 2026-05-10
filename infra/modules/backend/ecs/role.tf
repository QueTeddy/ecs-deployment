resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_task_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = lower("${var.ENV}-${var.PROJECT_NAME}-ecs-task-execution-role")
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "${var.ENV}-${var.PROJECT_NAME}-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
          ]
        Resource = [for s in aws_secretsmanager_secret.service_secrets : s.arn]
      }
    ]
  })
}
resource "aws_iam_role_policy" "ecs_secrets_redis_policy" {
  name = "${var.ENV}-${var.PROJECT_NAME}-redis-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
          ]
        Resource = "${aws_secretsmanager_secret.redis_password.arn}"
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name               = lower("${var.ENV}-${var.PROJECT_NAME}-ecs-task-role")
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "app_resources_policy" {
  name = "${var.ENV}-${var.PROJECT_NAME}-app-resources-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Permissions
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.MEDIAASSET_BUCKET}",
          "arn:aws:s3:::${var.MEDIAASSET_BUCKET}/*"
        ]
      },
      # SQS Permissions
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# resource "aws_iam_service_linked_role" "ecs_managed_control_plane" {
#   aws_service_name = "ecs.amazonaws.com"
# }