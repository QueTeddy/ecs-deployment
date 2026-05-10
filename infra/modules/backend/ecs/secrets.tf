locals {
  # Decodes the static secrets fetched from AWS Secrets Manager
  s = jsondecode(data.aws_secretsmanager_secret_version.static_secrets.secret_string)
}

resource "aws_secretsmanager_secret" "service_secrets" {
  for_each = var.SERVICE_CONFIG
  name     = "${var.ENV}/${var.PROJECT_NAME}/${each.key}/secrets"
}


resource "aws_secretsmanager_secret_version" "service_secrets_val" {
  for_each  = var.SERVICE_CONFIG
  secret_id = aws_secretsmanager_secret.service_secrets[each.key].id
  secret_string = jsonencode(merge(
    {
      for svc_key, svc_config in var.SERVICE_CONFIG : 
      "${upper(svc_key)}_SERVICE_URL" => "http://${svc_key}.local:${svc_config.container_port}"
    },
    {
    ENV                      = "${var.ENV}" == "prod" ? "production" : "development"
    DB_USER                  = "${var.DB_USER}"
    DB_PASS                  = "${var.DB_PASSWORD}"
    DB_NAME                  = "${lower(each.key)}_db"
    DB_HOST                  = "${var.DB_HOST}"
    DB_PORT                  = "${var.DB_PORT}"
    JWT_SECRET               = local.s.JWT_SECRET
    JWT_REFRESH_SECRET       = local.s.JWT_REFRESH_SECRET
    JWT_ALGORITHM            = "HS256"
    ACCESS_TOKEN_EXPIRES_MIN = "1440"
    GOOGLE_MAPS_API_KEY      = local.s.GOOGLE_MAPS_API_KEY
    AWS_REGION               = "${var.REGION}"
    AWS_ACCESS_KEY           = local.s.AWS_ACCESS_KEY
    AWS_SECRET               = local.s.AWS_SECRET
    PAYSTACK_SECRET_KEY      = "${var.PAYSTACK_SECRET_KEY}"
    AGORA_APP_CERTIFICATE    = "${var.AGORA_APP_CERTIFICATE}"
    ETH_RPC_URL              = local.s.ETH_RPC_URL
    KR_ADMIN_PRIVATE_KEY     = local.s.KR_ADMIN_PRIVATE_KEY
    KR_ADMIN_ADDRESS         = local.s.KR_ADMIN_ADDRESS
    CCRT_CONTRACT_ADDRESS    = local.s.CCRT_CONTRACT_ADDRESS
    APPLE_CLIENT_ID_DRIVER   = local.s.APPLE_CLIENT_ID_DRIVER
    APPLE_CLIENT_ID_RIDER    = local.s.APPLE_CLIENT_ID_RIDER
    MORALIS_API_KEY          = local.s.MORALIS_API_KEY
  }))
}

resource "aws_secretsmanager_secret" "redis_password" {
  name = "${var.ENV}-${var.PROJECT_NAME}-redis-secret"
  tags = var.COMMON_TAGS
}


resource "random_password" "redis_password" {
  length           = 16
  special          = true
  # Only includes symbols allowed by your constraint: _ . - , /
  override_special = "_.-,/"
}

resource "aws_secretsmanager_secret_version" "redis_password" {
  secret_id     = aws_secretsmanager_secret.redis_password.id
  secret_string = jsonencode({
    redis_password = "${random_password.redis_password.result}"
  })
}
