resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.webapp.id
  depends_on    = [aws_internet_gateway.ecs_deploymenmt]
  tags          = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-nat-gw-%s", element(var.azs, count.index))}))
}