resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.ecs_deploymenmt.id

  tags = {
    Name = "${var.ENV}-${var.PROJECT_NAME}-private-rt-${var.azs[count.index]}"
  }
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(var.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecs_deploymenmt.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_deploymenmt[0].id
  }

  tags = {
    Name = "${var.ENV}-${var.PROJECT_NAME}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.webapp[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}