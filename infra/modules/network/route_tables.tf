resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.ecs_deployment.id

  tags = {
    Name = "${var.ENV}-${var.PROJECT_NAME}-private-rt-${element(var.azs, count.index)}"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecs_deployment.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_deployment.id
  }

  tags = {
    Name = "${var.ENV}-${var.PROJECT_NAME}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}