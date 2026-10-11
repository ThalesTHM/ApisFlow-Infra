# ApisFlow Infra

Infraestrutura AWS do ApisFlow em Terraform (região `us-east-1`).

## Estrutura

- `bootstrap/`: bucket S3 versionado que guarda o state remoto (state local, roda uma vez).
- `modules/`: módulos reutilizáveis (`network`, `ecr`, ...).
- `envs/homolog`, `envs/prod`: um state por ambiente.

## Custos

Recursos que cobram por hora (NAT Gateway, ALB, RDS, Redis, tasks Fargate) só são criados
quando `enabled = true` no `terraform.tfvars` do ambiente. Por padrão ficam desligados.

## Uso

```sh
# 1. State remoto (uma vez; ver comentário em bootstrap/main.tf)
cd bootstrap
terraform init
terraform apply
terraform output state_bucket

# 2. Ambiente
cd ../envs/homolog
terraform init -backend-config="bucket=<state_bucket>"
terraform plan
terraform apply
```

Segredos (senha do banco, JWT) ficam no AWS Secrets Manager, nunca neste repositório.
