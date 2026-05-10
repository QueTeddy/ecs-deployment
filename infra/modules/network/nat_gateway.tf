resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.webapp[0].id
  depends_on    = [aws_internet_gateway.ecs_deployment]
  tags = merge(
                  var.COMMON_TAGS, 
                  {
                    "Name" = "${var.ENV}-${var.PROJECT_NAME}-nat-gw"
                  }
  )
}