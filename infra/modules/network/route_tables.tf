resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ecs_deployment.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = merge(var.COMMON_TAGS, { 
    Name = "${var.ENV}-${var.PROJECT_NAME}-private-rt" 
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecs_deployment.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_deployment.id
  }

  tags = merge(var.COMMON_TAGS, { 
    Name = "${var.ENV}-${var.PROJECT_NAME}-public-rt" 
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.webapp)
  subnet_id      = aws_subnet.webapp[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}