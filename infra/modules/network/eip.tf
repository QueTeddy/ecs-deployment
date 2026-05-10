resource "aws_eip" "nateip" {
  domain = "vpc"
  tags   = merge(var.COMMON_TAGS, tomap({"Name"= format("${var.ENV}-${var.PROJECT_NAME}-eip-%s", element(var.azs, count.index))}))
}