resource "aws_subnet" "webapp" {
  vpc_id            = "${aws_vpc.ecs_deploymenmt.id}"
  cidr_block        = "${var.public_subnets}"
  availability_zone = "${element(var.azs, count.index)}"
  tags              = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-subnet-public-%s", element(var.azs, count.index))}))
}
