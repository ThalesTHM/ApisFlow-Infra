environment = "homolog"
vpc_cidr    = "10.10.0.0/16"

# false = nada que cobre por hora (NAT, ALB, RDS, Redis, Fargate, alarmes)
enabled = false

single_nat         = true
redis_nodes        = 1
desired_count      = 1
log_retention_days = 14

# Homologação cria o OIDC provider do GitHub (um por conta) e é aplicada antes de prod.
create_github_oidc_provider = true
github_subjects = [
  "repo:ThalesTHM/ApisFlow-Backend:ref:refs/heads/staging",
  "repo:ThalesTHM/ApisFlow-Frontend:ref:refs/heads/staging",
]
