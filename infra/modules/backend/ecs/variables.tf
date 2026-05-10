variable "ENV" {}

variable "PROJECT_NAME" {}

variable "COMMON_TAGS" {}

variable "ECR_REPOSITORIES" {}

variable "ACCOUNT_ID" {}

variable "REGION" {}

variable "SERVICE_CONFIG" {}

variable "DB_USER" {}

variable "DB_PASSWORD" {}

variable "DB_NAME" {}

variable "DB_HOST" {}

variable "DB_PORT" {}

variable "vpc_id" {
  type = string
  description = "VPC id where ECS services will run"
}

variable "BACKEND_SUBNETS" {
  type        = list(string)
  description = "List of private subnets to run ECS tasks in"
}

variable "enable_alb" {
  type    = bool
  default = false
  description = "Whether ALB and target groups are provided and should be used"
}

variable "BACKEND_SECURITY_GROUP" {
  type        = string
  description = "ID of service security group created by network module"
}


variable "WEBAPP_SUBNETS" {}

variable "WEBAPP_SECURITY_GROUP_ID" {}

variable "WEBAPP_DNS" {}

variable "API_DOMAIN" {}

