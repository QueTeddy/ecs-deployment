resource "aws_eip" "nateip" {
  domain = "vpc"
  tags   = merge(var.COMMON_TAGS, {
    "Name" = "${var.ENV}-${var.PROJECT_NAME}-eip"
  })
}