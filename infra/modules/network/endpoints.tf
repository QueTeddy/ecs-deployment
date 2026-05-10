


# resource "aws_vpc_endpoint" "s3" {
#   count = "${var.enable_s3_endpoint}"

#   vpc_id       = "${aws_vpc.mod.id}"
#   service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
# }

# resource "aws_vpc_endpoint_route_table_association" "private_s3" {
#   count = "${var.enable_s3_endpoint ? length(var.private_subnets) : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
#   route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
# }

# resource "aws_vpc_endpoint_route_table_association" "public_s3" {
#   count = "${var.enable_s3_endpoint ? length(var.public_subnets) : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
#   route_table_id  = "${aws_route_table.public.id}"
# }

# data "aws_vpc_endpoint_service" "dynamodb" {
#   service = "dynamodb"
# }

# resource "aws_vpc_endpoint" "dynamodb" {
#   count = "${var.enable_dynamodb_endpoint}"

#   vpc_id       = "${aws_vpc.mod.id}"
#   service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
# }

# resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
#   count = "${var.enable_dynamodb_endpoint ? length(var.private_subnets) : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
#   route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
# }

# resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
#   count = "${var.enable_dynamodb_endpoint ? length(var.public_subnets) : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
#   route_table_id  = "${aws_route_table.public.id}"
# }

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.enable_secrets_vpc_endpoint ? 1 : 0
  vpc_id              = aws_vpc.ecs_deploymenmt.id
  service_name        = data.aws_vpc_endpoint_service.secretsmanager.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.backend[*].id
  security_group_ids  = [aws_security_group.secrets_manager_endpoint[0].id]
  private_dns_enabled = true
  tags                = var.COMMON_TAGS
} 
