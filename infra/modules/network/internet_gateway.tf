resource "aws_internet_gateway" "ecs_deployment" {
  vpc_id   = aws_vpc.ecs_deployment.id
  tags     = merge(var.COMMON_TAGS, {
    "Name" = "${var.ENV}-${var.PROJECT_NAME}-igw"
  })
}



