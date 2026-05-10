data "aws_route53_zone" "ecs_deploymenmt" {
  name         = var.WEBAPP_DNS
  private_zone = false
}

resource "aws_route53_record" "ecs_deploymenmt" {
  zone_id = data.aws_route53_zone.ecs_deploymenmt.zone_id
  name    = "api.${var.WEBAPP_DNS}"
  type    = "A"

  alias {
    name                   = var.ALB_DNS
    zone_id                = var.ALB_ZONE_ID
    evaluate_target_health = true
  }
}


