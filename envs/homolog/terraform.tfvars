environment = "homolog"
vpc_cidr    = "10.10.0.0/16"

# false = nada que cobre por hora (NAT, ALB, RDS, Redis, Fargate, alarmes)
enabled = false

single_nat         = true
redis_nodes        = 1
desired_count      = 1
log_retention_days = 14

rds_backup_retention_days = 7

# Homologação cria o OIDC provider do GitHub (um por conta) e é aplicada antes de prod.
# Só jobs no GitHub Environment "homolog" (restrito à branch staging) assumem a role.
create_github_oidc_provider = true
github_subjects = [
  "repo:ThalesTHM/ApisFlow-Backend:environment:homolog",
  "repo:ThalesTHM/ApisFlow-Frontend:environment:homolog",
]

# Role do pipeline do repositório de infra (plan em pull requests); criada só aqui.
infra_ci_repo = "ThalesTHM/ApisFlow-Infra"
state_bucket  = "apisflow-tfstate-227536678259"

# HTTPS com domínio próprio (opcional): exige hosted zone no Route 53.
# domain_name      = "homolog.seudominio.com.br"
# hosted_zone_name = "seudominio.com.br"
