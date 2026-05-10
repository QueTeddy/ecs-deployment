# # Outputs for the db module


# output "WEBAPP_SECURITY_GROUP_ID" {
#   value = aws_security_group.webapp_security_group.id
#   description = "Webapp security group id"
# }

# output "public_subnet_ids" {
#   value       = aws_subnet.webapp[*].id
#   description = "list of webapp subnet IDs"
# }


# output "backend_subnet_ids" {
#   value       = aws_subnet.backend[*].id
#   description = "list of backend subnet IDs"
# }


# output "backend_security_group_id" {
#   value       = aws_security_group.backend_sg.id
#   description = "Service security group id for ECS internal services"
# }

# output "vpc_id" {
#   value       = aws_vpc.ecs_deploymenmt.id
#   description = "VPC id"
# }

# output "service_security_group_id" {
#   value       = aws_security_group.service_security_group.id
#   description = "Service security group id for ECS internal services"
# }

# output "webapp_security_group_id" {
#   value       = aws_security_group.webapp_security_group.id
#   description = "Webapp security group id for public ECS services"
# }

# output "secretsmanager_vpc_endpoint_id" {
#   value       = var.enable_secrets_vpc_endpoint ? aws_vpc_endpoint.secretsmanager[0].id : ""
#   description = "ID of the Secrets Manager VPC endpoint (if created)"
# }

# output "secretsmanager_vpc_endpoint_network_interface_ids" {
#   value       = var.enable_secrets_vpc_endpoint ? aws_vpc_endpoint.secretsmanager[0].network_interface_ids : []
#   description = "Network interface IDs for the Secrets Manager endpoint"
# }

# output "secretsmanager_vpc_endpoint_sg_id" {
#   value       = var.enable_secrets_vpc_endpoint ? aws_security_group.secrets_manager_endpoint[0].id : ""
#   description = "Security group ID attached to the Secrets Manager endpoint"
# }