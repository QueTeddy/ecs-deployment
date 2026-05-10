locals {
  ACCOUNTID            = data.aws_caller_identity.current.account_id
  AVAILABILITY_ZONES   = ["us-east-1a"]
  REPOSITORIES         = ["app-service"]
  REGION               = var.REGION
  COMMON_TAGS = {
    project     = var.PROJECT_NAME
    environment = var.ENVIRONMENT
    managedBy   = "ebhamenteddyjr@gmail.com"
    name        = "ecs-deploymenmt"
  }
}



# network module
module network {
  source               = "./modules/network"
  ENV                  = var.ENVIRONMENT
  PROJECT_NAME         = var.PROJECT_NAME
  azs                  = local.AVAILABILITY_ZONES
  cidr                 = "10.0.0.0/16"
  app_subnets          = ["10.0.3.0/24"]
  public_subnets       = ["10.0.5.0/24"]
  COMMON_TAGS          = local.COMMON_TAGS
  SERVICE_CONFIG       = var.SERVICE_CONFIG

}

# ECR Repositories
module "ecr" {
  source               = "./modules/backend/ecr"
  ENV                  = var.ENVIRONMENT
  PROJECT_NAME         = var.PROJECT_NAME
  COMMON_TAGS          = local.COMMON_TAGS
  ECR_REPOSITORIES     = local.REPOSITORIES
}

module "ecs" {
  source                    = "./modules/backend/ecs"
  ENV                       = var.ENVIRONMENT
  PROJECT_NAME              = var.PROJECT_NAME
  COMMON_TAGS               = local.COMMON_TAGS
  ECR_REPOSITORIES          = local.REPOSITORIES
  ACCOUNT_ID                = local.ACCOUNTID
  REGION                    = local.REGION
  vpc_id                    = module.network.vpc_id
  BACKEND_SUBNETS           = module.network.app_subnet_ids
  WEBAPP_SUBNETS            = module.network.public_subnet_ids
  enable_alb                = false
  BACKEND_SECURITY_GROUP    = module.network.backend_security_group_id
  WEBAPP_SECURITY_GROUP_ID  = module.network.WEBAPP_SECURITY_GROUP_ID
  SERVICE_CONFIG            = var.SERVICE_CONFIG
}

# # Route 53 Records
# module "route53" {
#   source               = "./modules/route53"
#   ENV                  = var.ENVIRONMENT
#   PROJECT_NAME         = var.PROJECT_NAME
#   COMMON_TAGS          = local.COMMON_TAGS
#   WEBAPP_DNS           = var.WEBAPP_DNS
#   ALB_DNS              = module.ecs.alb_dns
#   ALB_ZONE_ID          = module.ecs.alb_zone_id
# }
