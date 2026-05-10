resource "aws_vpc" "ecs_deploymenmt" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.COMMON_TAGS, { Name = "${var.ENV}-${var.PROJECT_NAME}-vpc"  })
}
