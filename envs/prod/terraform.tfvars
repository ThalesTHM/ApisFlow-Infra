environment = "prod"
vpc_cidr    = "10.20.0.0/16"

# false = nada que cobre por hora (NAT, ALB, RDS, Redis, Fargate, alarmes)
enabled = false

single_nat              = false
rds_multi_az            = true
rds_deletion_protection = true
redis_nodes             = 2
desired_count           = 2
enable_autoscaling      = true
log_retention_days      = 30

# Deploy de produção só por jobs no GitHub Environment "production" (com aprovação manual).
create_github_oidc_provider = false
github_subjects = [
  "repo:ThalesTHM/ApisFlow-Backend:environment:production",
  "repo:ThalesTHM/ApisFlow-Frontend:environment:production",
]
