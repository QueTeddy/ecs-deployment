data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_secretsmanager_secret_version" "static_secrets" {
  secret_id = "${var.ENV}/${var.PROJECT_NAME}/static-secrets"
}
