resource "aws_cloudwatch_log_group" "ecs_cw_log_group" {
  for_each = toset(var.ECR_REPOSITORIES)
  retention_in_days = 1
  name     = lower("${var.ENV}-${var.PROJECT_NAME}-${each.key}-logs")
  tags     = var.COMMON_TAGS
}


