resource "aws_subnet" "backend" {
  count             = "${length(var.backend_subnets)}"
  vpc_id            = "${aws_vpc.ecs_deploymenmt.id}"
  cidr_block        = "${var.backend_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  tags              = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-subnet-backend-%s", element(var.azs, count.index))}))
}