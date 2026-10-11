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

rds_backup_retention_days = 14

# Deploy de produção só por jobs no GitHub Environment "production" (com aprovação manual).
create_github_oidc_provider = false
# Formato imutável do claim sub (dono@id/repo@id), padrão do GitHub para estes repositórios.
github_subjects = [
  "repo:ThalesTHM@122706248/ApisFlow-Backend@1351686381:environment:production",
  "repo:ThalesTHM@122706248/ApisFlow-Frontend@1351789024:environment:production",
]

# HTTPS com domínio próprio (opcional): exige hosted zone no Route 53.
# domain_name      = "seudominio.com.br"
# hosted_zone_name = "seudominio.com.br"
