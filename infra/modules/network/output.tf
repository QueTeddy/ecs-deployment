output "public_subnet_ids" {
  value       = aws_subnet.webapp[*].id
  description = "list of webapp subnet IDs"
}


output "app_subnet_ids" {
  value       = aws_subnet.app[*].id
  description = "list of app subnet IDs"
}


output "app_security_group_id" {
  value       = aws_security_group.service_security_group.id
  description = "APP Service security group id for ECS internal services"
}

output "vpc_id" {
  value       = aws_vpc.ecs_deployment.id
  description = "VPC id"
}


output "webapp_security_group_id" {
  value       = aws_security_group.webapp_security_group.id
  description = "Webapp security group id for public ECS services"
}

output "app_security_group_id" {
  value       = aws_security_group.service_security_group.id
  description = "Service security group id for ECS internal services"
}