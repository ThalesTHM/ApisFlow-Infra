environment = "homolog"
vpc_cidr    = "10.10.0.0/16"

# false = nada que cobre por hora (NAT, ALB, RDS, Redis, Fargate, alarmes)
enabled = true

single_nat         = true
redis_nodes        = 1
desired_count      = 1
log_retention_days = 14

rds_backup_retention_days = 7

# Conta admin (organização "admin", admin@admin.com) criada a cada deploy.
# Senha no Secrets Manager: apisflow/homolog/admin-password
bootstrap_admin = true

# Homologação cria o OIDC provider do GitHub (um por conta) e é aplicada antes de prod.
# Só jobs no GitHub Environment "homolog" (restrito à branch staging) assumem a role.
create_github_oidc_provider = true
# Formato imutável do claim sub (dono@id/repo@id), padrão do GitHub para estes repositórios.
github_subjects = [
  "repo:ThalesTHM@122706248/ApisFlow-Backend@1351686381:environment:homolog",
  "repo:ThalesTHM@122706248/ApisFlow-Frontend@1351789024:environment:homolog",
]

# Role do pipeline do repositório de infra (plan em pull requests); criada só aqui.
infra_ci_repo = "ThalesTHM@122706248/ApisFlow-Infra@1414752743"
state_bucket  = "apisflow-tfstate-227536678259"

# HTTPS com domínio próprio (opcional): exige hosted zone no Route 53.
# domain_name      = "homolog.seudominio.com.br"
# hosted_zone_name = "seudominio.com.br"
