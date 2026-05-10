resource "aws_internet_gateway" "ecs_deployment" {
  count    = "${length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id   = aws_vpc.ecs_deployment.id
  tags     = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-igw-%s", element(var.azs, count.index))}))
}



