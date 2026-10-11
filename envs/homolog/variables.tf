variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "apisflow"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "enabled" {
  description = "Liga os recursos que cobram por hora (NAT, ALB, RDS, Redis, Fargate, alarmes)"
  type        = bool
  default     = false
}

variable "single_nat" {
  description = "Um único NAT (true) ou um por AZ (false)"
  type        = bool
  default     = true
}

variable "rds_multi_az" {
  type    = bool
  default = false
}

variable "rds_backup_retention_days" {
  type    = number
  default = 7
}

variable "rds_deletion_protection" {
  type    = bool
  default = false
}

variable "redis_nodes" {
  description = "1 = só primário; 2 = primário + réplica"
  type        = number
  default     = 1
}

variable "desired_count" {
  description = "Tasks por service"
  type        = number
  default     = 1
}

variable "enable_autoscaling" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "domain_name" {
  description = "Domínio do ambiente para HTTPS (Route 53 + ACM). Vazio = só HTTP pelo DNS do ALB"
  type        = string
  default     = ""
}

variable "hosted_zone_name" {
  description = "Hosted zone existente no Route 53 que contém domain_name"
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "E-mail dos alarmes do CloudWatch"
  type        = string
  default     = ""
}

variable "create_github_oidc_provider" {
  description = "Só um ambiente da conta cria o OIDC provider do GitHub"
  type        = bool
}

variable "github_subjects" {
  description = "Repositórios/branches que podem assumir a role de deploy"
  type        = list(string)
}

variable "infra_ci_repo" {
  description = "ORG/REPO da infra; só um ambiente cria a role do pipeline de infra"
  type        = string
  default     = ""
}

variable "state_bucket" {
  type    = string
  default = ""
}
