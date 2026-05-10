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
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name               = lower("${var.ENV}-${var.PROJECT_NAME}-ecs-task-role")
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

