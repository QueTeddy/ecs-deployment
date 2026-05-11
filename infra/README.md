# ECS-deploymenmt-ride — infra (backend)

## Overview
This folder contains Terraform code to provision the backend infrastructure for the Klimate Ride project into AWS.

Primary responsibilities:
- Create VPC, subnets, and security groups (module: `network`).
- Provision Aurora PostgreSQL serverless and Secrets Manager entries (module: `database`).
- Create ECR repositories for service images (module: `backend/ecr`).
- Create an ECS cluster (Fargate), task definitions, services, CloudWatch log groups, and autoscaling (module: `backend/ecs`).

---

## Architecture (text diagram)

VPC (modules/network)
  ├─ Subnets: public, backend, database
  ├─ Security groups
  └─ Outputs: `vpc_id`, `backend_subnet_ids`, `db_subnet_group_id`, `DB_SECURITY_GROUP_ID`

ECR (modules/backend/ecr)
  └─ Repositories for services listed in `locals.REPOSITORIES`

ECS (modules/backend/ecs)
  ├─ `aws_ecs_cluster` (Fargate)
  ├─ Task definitions from `service_config` map
  ├─ `aws_ecs_service` per entry (supports ALB via dynamic block)
  ├─ CW Log Groups per repository
  ├─ IAM role + `AmazonECSTaskExecutionRolePolicy`
  └─ AppAutoscaling targets & policies

Database (modules/database)
  ├─ Aurora PostgreSQL (serverless)
  └─ SecretsManager for DB credentials

---

## Key files
- `main.tf` — top-level module composition & locals
- `variable.tf` — root variables
- `data.tf` — account/region/AZ data
- `modules/network/*` — VPC, subnets, SGs, outputs
- `modules/database/*` — RDS & secrets
- `modules/backend/ecr/*` — ECR repos
- `modules/backend/ecs/*` — ECS cluster, tasks, services, autoscaling, logs, IAM

---

## Important variables & contract notes 📝
- `modules/backend/ecs` expects a `service_config` map (type `map(object({...}))`). Each entry must include:
  - `name`, `is_public`, `container_port`, `host_port`, `cpu`, `memory`, `desired_count`
  - `alb_target_group` (port, protocol, path_pattern, health_check_path, priority)
  - `auto_scaling` (max_capacity, min_capacity, cpu.target_value, memory.target_value)

- ALB integration is supported by the ECS module via:
  - `enable_alb` (bool, default `false`)
  - `public_alb_target_groups` and `internal_alb_target_groups` (maps of `{ arn = string }`)
  - `public_alb_security_group_id` / `internal_alb_security_group_id`

- Network outputs used by ECS:
  - `module.network.vpc_id`
  - `module.network.backend_subnet_ids` (used as both `public_subnets` and `private_subnets` as configured currently)
  - `module.network.service_security_group_id` (service SG for internal ECS services)
  - `module.network.webapp_security_group_id` (webapp SG for public ECS services)

---

## Current gaps & action items ⚠️
- The repo list in `locals.REPOSITORIES` must include `driver` if `driver`-task references remain. Ensure `REPOSITORIES` includes any repo referenced by `modules/backend/ecs` (e.g., `driver`).
- ALB support is available in the ECS module; verify `enable_alb` and listener configuration if you need public routing.
- `service_config` is not defined in the root; add it via `dev.auto.tfvars` or pass into `module "ecs"`.
- Backend S3 remote state backend is declared but requires configuration (bucket, region, key, etc.).
- CI/CD for building/pushing Docker images into ECR is not present in repo — implement or push images manually before applying.
- Security & least privilege review: some SGs and IAM attachments are permissive; tighten as needed. Note: service/webapp SGs are now created in `modules/network` and exported to ECS via module outputs.

---

## Example `service_config` snippet (add to `dev.auto.tfvars`)

```hcl
service_config = {
  service = {
    name           = "driver-service"
    is_public      = false
    container_port = 8001
    host_port      = 8001
    cpu            = 256
    memory         = 512
    desired_count  = 1

    alb_target_group = {
      port              = 8001
      protocol          = "HTTP"
      path_pattern      = ["/driver*"]
      health_check_path = "/health"
      priority          = 10
    }

    auto_scaling = {
      max_capacity = 4
      min_capacity = 1
      cpu = { target_value = 60 }
      memory = { target_value = 70 }
    }
  }
}
```

---

## Notes on Deployment
This repo is designed for cloud deployment via GitHub Actions and remote Terraform state.
The commands below are useful for local code inspection or troubleshooting only; the standard deployment path is through the CI/CD workflow.

## Commands (advanced / inspection only)
- terraform init
- terraform plan -var-file=config/dev.auto.tfvars
- terraform apply -var-file=config/dev.auto.tfvars

---

## Recommended next steps ✅
1. Add `driver` to `locals.REPOSITORIES` or remove driver references in `ecs` module.
2. Provide `service_config` values (per environment) and commit `dev.auto.tfvars` (or keep out of git and use a CI secret).
3. Implement or wire an ALB module if you want public routing across services.
4. Add CI to build & push Docker images to ECR & then trigger Terraform deployments.
5. Tighten SG and IAM rules, add log retention/alarms, and review backups/maintenance windows for the DB.
