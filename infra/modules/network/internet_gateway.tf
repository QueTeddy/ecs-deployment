resource "aws_internet_gateway" "ecs_deploymenmt" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id = aws_vpc.ecs_deploymenmt.id
  tags              = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-igw-%s", element(var.azs, count.index))}))
}



