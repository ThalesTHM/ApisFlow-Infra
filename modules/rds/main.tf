locals {
  name  = "${var.project}-${var.environment}"
  count = var.enabled ? 1 : 0
}

resource "aws_db_subnet_group" "this" {
  count = local.count

  name       = local.name
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  count = local.count

  name   = "${local.name}-pg16"
  family = "postgres16"

  # Força conexões com SSL
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

# Dois papéis no banco, para o Row-Level Security valer:
# - owner (usuário mestre): dono das tabelas, usado só nas migrações;
# - app_user: usado pela aplicação, sem superuser e sem BYPASSRLS
#   (criado pela tarefa de migração com a senha abaixo).
# As senhas ficam no Secrets Manager; sem caracteres especiais para caber na URL.
resource "random_password" "owner" {
  count = local.count

  length  = 40
  special = false
}

resource "random_password" "app" {
  count = local.count

  length  = 40
  special = false
}

resource "aws_db_instance" "this" {
  count = local.count

  identifier     = local.name
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.owner_username
  password = random_password.owner[0].result

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  parameter_group_name   = aws_db_parameter_group.this[0].name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_days
  deletion_protection     = var.deletion_protection

  performance_insights_enabled = true
  auto_minor_version_upgrade   = true

  skip_final_snapshot       = !var.deletion_protection
  final_snapshot_identifier = var.deletion_protection ? "${local.name}-final" : null
  apply_immediately         = !var.deletion_protection
}

locals {
  db_endpoint = var.enabled ? "${aws_db_instance.this[0].address}:${aws_db_instance.this[0].port}/${var.db_name}?schema=public&sslmode=require" : ""

  secrets = var.enabled ? {
    # Usado pela aplicação (papel sem privilégios de bypass)
    "database-url" = "postgresql://${var.app_username}:${random_password.app[0].result}@${local.db_endpoint}"
    # Usado só pela tarefa de migração (dono das tabelas)
    "migration-database-url" = "postgresql://${var.owner_username}:${random_password.owner[0].result}@${local.db_endpoint}"
    # Senha que a migração aplica ao papel app_user
    "app-db-password" = random_password.app[0].result
  } : {}
}

# for_each usa só os nomes (as senhas são sensíveis e não podem ser chave).
resource "aws_secretsmanager_secret" "db" {
  for_each = var.enabled ? toset(["database-url", "migration-database-url", "app-db-password"]) : toset([])

  name                    = "${var.project}/${var.environment}/${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  for_each = aws_secretsmanager_secret.db

  secret_id     = each.value.id
  secret_string = local.secrets[each.key]
}
