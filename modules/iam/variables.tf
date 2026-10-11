variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "files_bucket_arn" {
  type = string
}

variable "ecr_repository_arns" {
  type = list(string)
}

variable "create_github_oidc_provider" {
  description = "Cria o OIDC provider do GitHub (só um por conta)"
  type        = bool
}

variable "github_subjects" {
  description = "Valores aceitos do claim sub, ex.: repo:ORG/REPO:ref:refs/heads/staging"
  type        = list(string)
}

variable "infra_ci_repo" {
  description = "Repositório da infra como aparece no claim sub (ex.: ORG@id/REPO@id); vazio = não cria a role"
  type        = string
  default     = ""
}

variable "state_bucket" {
  description = "Bucket do state, para a role do pipeline de infra fazer o lock"
  type        = string
  default     = ""
}
