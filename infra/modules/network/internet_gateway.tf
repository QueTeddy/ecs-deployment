resource "aws_internet_gateway" "ecs_deployment" {
  vpc_id   = aws_vpc.ecs_deployment.id
  tags     = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-igw-%s")}))
}



