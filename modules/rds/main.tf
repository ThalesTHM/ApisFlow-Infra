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

resource "aws_db_instance" "this" {
  count = local.count

  identifier     = local.name
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = "app_owner"

  # Senha master gerada e guardada pelo RDS no Secrets Manager.
  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  parameter_group_name   = aws_db_parameter_group.this[0].name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = 7
  deletion_protection     = var.deletion_protection

  performance_insights_enabled = true
  auto_minor_version_upgrade   = true

  skip_final_snapshot       = !var.deletion_protection
  final_snapshot_identifier = var.deletion_protection ? "${local.name}-final" : null
  apply_immediately         = !var.deletion_protection
}
