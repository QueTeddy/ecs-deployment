variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "ENV" {}

variable "PROJECT_NAME" {}

variable "cidr" {
  description = "The CIDR block for the VPC"
}


variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
}

variable "app_subnets" {
  description = "A list of private subnets inside the VPC."
}

variable "azs" {}

variable "COMMON_TAGS" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "enable_secrets_vpc_endpoint" {
  description = "Create an interface VPC endpoint for AWS Secrets Manager"
  type        = bool
  default     = false
} 

variable "public_alb_security_group_id" {
  type    = string
  default = ""
  description = "Optional: ID of public ALB security group to allow into webapp SG"
}

variable "SERVICE_CONFIG" {}