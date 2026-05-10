resource "aws_ecr_repository" "ecr_repository" {
  for_each = toset(var.ECR_REPOSITORIES)
  name = lower("${var.ENV}-${var.PROJECT_NAME}-${each.key}-service")
  tags = var.COMMON_TAGS
}