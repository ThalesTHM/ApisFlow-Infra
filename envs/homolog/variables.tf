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

variable "certificate_arn" {
  description = "Certificado ACM para HTTPS. Vazio = só HTTP"
  type        = string
  default     = ""
}

variable "frontend_origin" {
  description = "URL pública do frontend (CORS). Vazio = DNS do ALB"
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
