data "aws_region" "current" {}

locals {
  name  = "${var.project}-${var.environment}"
  count = var.enabled ? 1 : 0
}

resource "aws_ecs_cluster" "this" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = toset(["backend", "frontend"])

  name              = "/ecs/${local.name}/${each.key}"
  retention_in_days = var.log_retention_days
}

# Segredo do JWT gerado aqui e lido pela task via campo `secrets`.
resource "random_password" "jwt" {
  count = local.count

  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt" {
  count = local.count

  name                    = "${var.project}/${var.environment}/jwt-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "jwt" {
  count = local.count

  secret_id     = aws_secretsmanager_secret.jwt[0].id
  secret_string = random_password.jwt[0].result
}

# Senha da conta admin criada pela migração (só homologação). Fica fora do
# "enabled" para continuar a mesma quando o ambiente é desligado e religado.
resource "random_password" "admin" {
  count = var.bootstrap_admin ? 1 : 0

  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "admin" {
  count = var.bootstrap_admin ? 1 : 0

  name                    = "${var.project}/${var.environment}/admin-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin" {
  count = var.bootstrap_admin ? 1 : 0

  secret_id     = aws_secretsmanager_secret.admin[0].id
  secret_string = random_password.admin[0].result
}

resource "aws_ecs_task_definition" "backend" {
  count = local.count

  family                   = "${local.name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = var.backend_image
      essential    = true
      portMappings = [{ containerPort = var.backend_port, protocol = "tcp" }]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT", value = tostring(var.backend_port) },
        { name = "JWT_EXPIRES_IN", value = "900" },
        { name = "CORS_ORIGIN", value = var.cors_origin },
        { name = "SWAGGER_ENABLED", value = tostring(var.swagger_enabled) },
        { name = "S3_BUCKET", value = var.files_bucket_name },
        { name = "AWS_REGION", value = data.aws_region.current.name },
      ]

      # Injetados pelo ECS a partir do Secrets Manager (task execution role).
      secrets = [
        { name = "DATABASE_URL", valueFrom = var.database_url_secret_arn },
        { name = "REDIS_URL", valueFrom = var.redis_url_secret_arn },
        { name = "JWT_SECRET", valueFrom = aws_secretsmanager_secret.jwt[0].arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service["backend"].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])
}

# Migração do banco como tarefa avulsa (run-task) antes de cada deploy:
# aplica as migrações com o papel dono e garante o papel app_user.
resource "aws_ecs_task_definition" "migrate" {
  count = local.count

  family                   = "${local.name}-migrate"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "migrate"
      image     = var.migrate_image
      essential = true
      command   = ["sh", "-c", "npx prisma migrate deploy && node scripts/ensure-app-role.js && node scripts/ensure-admin.js"]

      environment = concat(
        [{ name = "APP_DB_USER", value = "app_user" }],
        var.bootstrap_admin ? [
          { name = "BOOTSTRAP_TENANT_SLUG", value = "admin" },
          { name = "BOOTSTRAP_ADMIN_EMAIL", value = "admin@admin.com" },
        ] : [],
      )

      secrets = concat(
        [
          { name = "DATABASE_URL", valueFrom = var.migration_database_url_secret_arn },
          { name = "APP_DB_PASSWORD", valueFrom = var.app_db_password_secret_arn },
        ],
        var.bootstrap_admin ? [
          { name = "BOOTSTRAP_ADMIN_PASSWORD", valueFrom = aws_secretsmanager_secret.admin[0].arn },
        ] : [],
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service["backend"].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "migrate"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  count = local.count

  family                   = "${local.name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = var.frontend_image
      essential    = true
      portMappings = [{ containerPort = var.frontend_port, protocol = "tcp" }]

      # Lido pelo entrypoint do Nginx e gravado em /config.js na inicialização,
      # para a mesma imagem servir qualquer ambiente.
      environment = [
        { name = "API_URL", value = var.frontend_api_url },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service["frontend"].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

# O deploy (GitHub Actions) registra novas revisões da task definition,
# então o Terraform não deve reverter a revisão nem o desired_count.
resource "aws_ecs_service" "backend" {
  count = local.count

  name            = "backend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend[0].arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = var.backend_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "frontend" {
  count = local.count

  name            = "frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend[0].arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.app_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# Autoscaling por CPU (alvo 60%), usado em produção.
resource "aws_appautoscaling_target" "backend" {
  count = var.enabled && var.enable_autoscaling ? 1 : 0

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.backend[0].name}"
  min_capacity       = var.backend_desired_count
  max_capacity       = var.backend_max_count
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  count = var.enabled && var.enable_autoscaling ? 1 : 0

  name               = "${local.name}-backend-cpu"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.backend[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.backend[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.backend[0].resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
