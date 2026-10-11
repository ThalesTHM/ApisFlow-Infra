data "aws_caller_identity" "current" {}

locals {
  # Sem domínio próprio, o frontend é servido pelo DNS do ALB.
  frontend_origin = var.frontend_origin != "" ? var.frontend_origin : (
    module.alb.dns_name != null ? "http://${module.alb.dns_name}" : "http://localhost:3001"
  )
}

module "network" {
  source = "../../modules/network"

  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  enable_nat  = var.enabled
  single_nat  = var.single_nat
}

module "ecr" {
  source = "../../modules/ecr"

  project      = var.project
  environment  = var.environment
  repositories = ["backend", "frontend"]
}

module "s3" {
  source = "../../modules/s3"

  project              = var.project
  environment          = var.environment
  account_id           = data.aws_caller_identity.current.account_id
  cors_allowed_origins = [local.frontend_origin]
}

module "iam" {
  source = "../../modules/iam"

  project                     = var.project
  environment                 = var.environment
  files_bucket_arn            = module.s3.bucket_arn
  ecr_repository_arns         = values(module.ecr.repository_arns)
  create_github_oidc_provider = var.create_github_oidc_provider
  github_subjects             = var.github_subjects
}

module "rds" {
  source = "../../modules/rds"

  project             = var.project
  environment         = var.environment
  enabled             = var.enabled
  subnet_ids          = module.network.data_subnet_ids
  security_group_id   = module.network.security_group_ids.rds
  multi_az            = var.rds_multi_az
  deletion_protection = var.rds_deletion_protection
}

module "redis" {
  source = "../../modules/redis"

  project            = var.project
  environment        = var.environment
  enabled            = var.enabled
  subnet_ids         = module.network.data_subnet_ids
  security_group_id  = module.network.security_group_ids.redis
  num_cache_clusters = var.redis_nodes
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment       = var.environment
  enabled           = var.enabled
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  security_group_id = module.network.security_group_ids.alb
  certificate_arn   = var.certificate_arn
}

module "ecs" {
  source = "../../modules/ecs"

  project                   = var.project
  environment               = var.environment
  enabled                   = var.enabled
  app_subnet_ids            = module.network.app_subnet_ids
  security_group_id         = module.network.security_group_ids.ecs
  task_execution_role_arn   = module.iam.task_execution_role_arn
  task_role_arn             = module.iam.task_role_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  db_host                   = module.rds.address
  db_name                   = module.rds.db_name
  db_secret_arn             = module.rds.master_secret_arn
  redis_host                = module.redis.primary_endpoint
  redis_secret_arn          = module.redis.auth_secret_arn
  files_bucket_name         = module.s3.bucket_name
  cors_origin               = local.frontend_origin
  backend_desired_count     = var.desired_count
  frontend_desired_count    = var.desired_count
  enable_autoscaling        = var.enable_autoscaling
  log_retention_days        = var.log_retention_days
  swagger_enabled           = var.environment != "prod"
}

module "observability" {
  source = "../../modules/observability"

  project                    = var.project
  environment                = var.environment
  enabled                    = var.enabled
  alert_email                = var.alert_email
  alb_arn_suffix             = module.alb.arn_suffix
  ecs_cluster_name           = module.ecs.cluster_name
  rds_instance_id            = module.rds.instance_id
  redis_replication_group_id = module.redis.replication_group_id
}
