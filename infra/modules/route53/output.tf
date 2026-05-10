output "API_DOMAIN" {
  value =  aws_route53_record.ecs_deploymenmt.name
}