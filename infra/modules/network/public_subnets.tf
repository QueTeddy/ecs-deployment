resource "aws_subnet" "webapp" {
  count             = length(var.public_subnets)
  vpc_id            = "${aws_vpc.ecs_deployment.id}"
  cidr_block        = var.public_subnets[count.index]
  availability_zone = "${element(var.azs, count.index)}"
  tags = merge(var.COMMON_TAGS, {
    "Name" = format("${var.ENV}-${var.PROJECT_NAME}-subnet-public-%s", count.index + 1)
  })
}
