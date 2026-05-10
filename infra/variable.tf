
variable "REGION" {
  description = "AWS region to deploy resources"
}


variable "ENVIRONMENT" {}


variable "PROJECT_NAME" {}

variable "SERVICE_CONFIG" {
  type = map(object({
    name           = string
    is_public      = bool
    container_port = number
    host_port      = number
    cpu            = number
    memory         = number
    desired_count  = number

    alb_target_group = object({
      port              = number
      protocol          = string
      path_pattern      = list(string)
      health_check_path = string
      priority          = number
    })

    auto_scaling = object({
      max_capacity = number
      min_capacity = number
      cpu = object({
        target_value = number
      })
      memory = object({
        target_value = number
      })
    })
  }))

  default = {
    app_service = {
    name           = "app-service"
    is_public      = false
    container_port = 8001
    host_port      = 8001
    cpu            = 256
    memory         = 512
    desired_count  = 1

    alb_target_group = {
      port              = 8001
      protocol          = "HTTP"
      path_pattern      = ["/app-service*"]
      health_check_path = "/app-service/docs"
      priority          = 10
    }

    auto_scaling = {
      max_capacity = 2
      min_capacity = 1
      cpu = { target_value = 60 }
      memory = { target_value = 70 }
    }
  }

}

}
