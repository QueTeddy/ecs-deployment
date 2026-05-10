output "ecr_repositories" {
  value       = var.ECR_REPOSITORIES
  description = "List of ECR repositories the ECS module expects"
}

output "alb_dns" {
    value   = aws_lb.ecs_alb.dns_name
}

output "alb_zone_id" {
    value   = aws_lb.ecs_alb.zone_id
}

output "REDIS_PASSWORD" {
    value = random_password.redis_password.result
}

output "REDIS_HOST" {
    value = "${aws_service_discovery_service.redis_discovery.name}.${aws_service_discovery_private_dns_namespace.services_namespace.name}"
}
