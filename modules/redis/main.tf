locals {
  name  = "${var.project}-${var.environment}"
  count = var.enabled ? 1 : 0
}

resource "aws_elasticache_subnet_group" "this" {
  count = local.count

  name       = local.name
  subnet_ids = var.subnet_ids
}

# noeviction: filas (ex.: BullMQ) não podem perder jobs quando a memória encher.
resource "aws_elasticache_parameter_group" "this" {
  count = local.count

  name   = "${local.name}-redis7"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "random_password" "auth" {
  count = local.count

  length  = 48
  special = false
}

resource "aws_elasticache_replication_group" "this" {
  count = local.count

  replication_group_id = local.name
  description          = "Redis ${local.name}"

  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.this[0].name

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.num_cache_clusters > 1
  multi_az_enabled           = var.num_cache_clusters > 1

  subnet_group_name  = aws_elasticache_subnet_group.this[0].name
  security_group_ids = [var.security_group_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.auth[0].result

  snapshot_retention_limit = var.num_cache_clusters > 1 ? 3 : 0
  apply_immediately        = true
}

# URL completa (TLS + token) no formato que o cliente ioredis do backend espera.
resource "aws_secretsmanager_secret" "url" {
  count = local.count

  name                    = "${var.project}/${var.environment}/redis-url"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "url" {
  count = local.count

  secret_id     = aws_secretsmanager_secret.url[0].id
  secret_string = "rediss://:${random_password.auth[0].result}@${aws_elasticache_replication_group.this[0].primary_endpoint_address}:6379"
}
